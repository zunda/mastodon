# frozen_string_literal: true

require_relative './sanitize_config'

module CodeBlockFormatter
  class CodeBlock
    include ActionView::Helpers::TagHelper

    MULTILINE_CODEBLOCK_REGEXP = /^```(?<language>[^:\n]*)(?::(?<filename>[^\n]*))?\n(?<code>.*?)\n```$/m
    attr_reader :text, :filename, :language

    def self.match(text, pos = 0)
      match_data = text.match(MULTILINE_CODEBLOCK_REGEXP)
      return nil unless match_data
      CodeMatch.new(matched_text: match_data.to_s, pos: match_data.begin(0), code: CodeBlock.new(text: match_data[:code], language: match_data[:language], filename: match_data[:filename]))
    end

    def initialize(text:, filename: nil, language: nil)
      @text = text
      @filename = filename
      @language = language
    end

    def to_html
      content_tag(:code, escaped_text, data: { language: sanitized_language, filename: sanitized_filename }.compact)
    end

    def escaped_text
      @escaped_text ||= escape_once(text).split("\n").join('<br>').html_safe
    end

    def sanitized_language
      return nil if language.blank?
      @sanitized_language ||= Sanitize.fragment(language, Sanitize::Config::MASTODON_STRICT).gsub(/["']/, '')
    end

    def sanitized_filename
      return nil if filename.blank?
      @sanitized_filename ||= Sanitize.fragment(filename, Sanitize::Config::MASTODON_STRICT).gsub(/["']/, '')
    end
  end

  class InlineCode
    include ActionView::Helpers::TagHelper

    INLINE_CODE_REGEXP = /`(?<code>[^`\n]+?)`/
    attr_reader :text

    def self.match(text, pos = 0)
      match_data = text.match(INLINE_CODE_REGEXP)
      return nil unless match_data
      CodeMatch.new(matched_text: match_data.to_s, pos: match_data.begin(0), code: InlineCode.new(text: match_data[:code]))
    end

    def initialize(text:)
      @text = text
    end

    def inline?
      @inline
    end

    def to_html
      content_tag(:span, content_tag(:code, text, class: 'inline'))
    end

    def escaped_text
      @escaped_text ||= ERB::Util.html_escape(text)
    end
  end

  class CodeMatch
    attr_reader :matched_text, :pos, :code
    def initialize(matched_text:, pos:, code:)
      @matched_text = matched_text
      @pos = pos
      @code = code
    end

    def replace_matched_text(text, new_text)
      # Ensure there are two newlines around code literals to make code literals separated from other paragraph.
      text_before = pos > 0 ? text.slice(0..(pos - 1)) : ''
      text_before = end_with_double_newline(text_before) unless inline?
      text_after = text.slice((pos + matched_text.length)..-1)
      text_after = begin_with_double_newline(text_after) unless inline?

      text_before + new_text + text_after
    end

    def end_with_double_newline(text)
      return text if text.match(/\n\n\Z/)
      return text + "\n" if text.match(/\n\Z/)
      text + "\n\n"
    end

    def begin_with_double_newline(text)
      return text if text.match(/\A\n\n/)
      return "\n" + text if text.match(/\A\n/)
      "\n\n" + text
    end

    def inline?
      code.is_a? InlineCode
    end
  end

  # Replace code literals with marker to hide code literals from other formatters.
  class MarkerReplacer
    def initialize(text)
      @marker_index = text.scan(/\[\[\[codeblock(\d+)\]\]\]/).flatten.map(&:to_i).max || 0
      @remembered_triples = []
    end

    def replace_matched_text_with_marker(text, code_match)
      marker = create_marker
      associate_marker(marker: marker, code: code_match.code, original_text: code_match.matched_text)

      code_match.replace_matched_text(text, marker)
    end

    def replace_markers_with_codes(text)
      @remembered_triples.reverse.reduce(text) do |text, (marker, code, original_text)|
        text.sub(marker) { code.to_html }
      end
    end

    def replace_markers_with_original_texts(text)
      @remembered_triples.reverse.reduce(text) do |text, (marker, code, original_text)|
        text.sub(marker) { original_text }
      end
    end

    def replace_marker_with_space(text)
      @remembered_triples.reverse.reduce(text) do |text, (marker, code, original_text)|
        text.sub(marker) { ' ' }
      end
    end

    private

    def associate_marker(marker:, code:, original_text:)
      @remembered_triples << [marker, code, original_text]
    end

    def create_marker
      "[[[codeblock#{@marker_index += 1}]]]"
    end
  end

  module_function

  # Scan the given text and replace its code literals with markers.
  # marker_replacer can replace these markers with code blocks, original texts, or a space.
  def scan(text)
    marker_replacer = MarkerReplacer.new(text)

    pos = 0
    while match = CodeBlock.match(text, pos)
      text = marker_replacer.replace_matched_text_with_marker(text, match)
      pos = match.pos + 1
    end

    pos = 0
    while match = InlineCode.match(text, pos)
      text = marker_replacer.replace_matched_text_with_marker(text, match)
      pos = match.pos + 1
    end

    [text, marker_replacer]
  end

  # Scan the given text and replace its code literals with spaces.
  def remove_code_blocks(text)
    text, marker_replacer = scan(text)
    marker_replacer.replace_marker_with_space(text)
  end
end
