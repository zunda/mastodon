# This file is copied from
# https://github.com/arnt/uts58/blob/e7a205b/ruby/lib/uts58/extractor.rb
# and modified.
#
# Copyright (c) 2025, ICANN
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

module Uts58
  class Extractor

    # Returns every URL found in +text+ as a list of hashes:
    #
    #   { url: String, indices: [start, end] }
    #
    # the scheme is filled in as +https://+
    # if the input had none. +indices+ are codepoint offsets into
    # +text+, with +end+ exclusive, so <tt>text[start...end]</tt>
    # gives the substring that matched.
    #
    # Note that the start and end may not match the length of url. One
    # very common example is input that like "foo example.com bar",
    # where the URL will be https://example.com, including "https://".
    #
    # Returns an empty array if +text+ contains no links.
    #
    # +options+ follows twitter-text: pass
    # <tt>extract_url_without_protocol: false</tt> to find only links
    # that start with +http://+ or +https://+. UTS58 doesn't require a
    # scheme, so the default is +true+.
    def extract_urls_with_indices(text, options = {})
      without_protocol = options.fetch(:extract_url_without_protocol, true)
      result = []
      # The '@' in the negative lookbehind is non-obvious part: UTS58
      # has no userinfo, so a host that immediately follows an '@'
      # cannot be a link to https://. An email address (or a
      # bluesky/mastodon one) is possible. The rest of the set just
      # keeps a trigger from firing inside a word or path.
      text.to_enum(:scan,/(?<![-\p{Alnum}\p{M}.\/@])(?=\p{Alnum}[-\p{L}\p{N}\p{M}\u00DF\u03C2\u06FD\u06FE\u0F0B\u3007]*[\.:。])/).map{Regexp.last_match}.each do |match|
        # get rid of a leading protocol. We also tolerate letter/mark/number
        # characters between the trigger and the scheme, so that input
        # like "テストhttp://example.com" attaches the scheme correctly:
        # the trigger fires at offset 0 (the start of "テスト") because
        # nothing precedes it, and the actual link begins three
        # codepoints later.
        s = match.post_match
        scheme_match = /\A([\p{Han}\p{Hiragana}\p{Katakana}\p{Hangul}\p{Thai}\p{Lao}\p{Khmer}\p{Myanmar}]*?)(https?:\/\/)/i.match(s)
        if scheme_match
          scheme_offset = scheme_match[1].length
          proto = scheme_match[2]
          s = scheme_match.post_match
        else
          next unless without_protocol
          scheme_offset = 0
          proto = "https://"
        end
        # look for the prefix that might be a hostname or an IDN.
        # this is a somewhat sloppy match, with a few false positives.
        prefix = /\A([-\p{L}\p{N}\p{M}\u00DF\u03C2\u06FD\u06FE\u0F0B\u3007]+[\.。]){1,4}[-\p{L}\p{N}\p{M}]+(?![-\p{L}\p{N}\p{M}])/.match(s)
        if prefix && prefix[0].length < 254
          host_raw = prefix.match(0).gsub(/。/, ".")
          next unless valid_labels?(host_raw)
          hn = SimpleIDN.to_unicode(host_raw)
          begin
            about = PublicSuffix.parse(hn,
                                       ignore_private: true,
                                       default_rule: nil)
            if about && about.tld != "invalid" then
              # at this point, we do have enough to mark something,
              # the question is how much. there may be a trailing
              # port, then a path, then a query, finally a fragment.
              rest = prefix.post_match
              # "example.com." keeps its trailing dot only when a path, query,
              # or fragment follows; at the end of a sentence it's prose (UTS58).
              if rest[0] == "." && ["/", "?", "#"].include?(rest[1])
                rest = rest[1..]
              end
              # a port number must be 1..65535
              port = /\A:(\d+)/.match(rest)
              if port
                n = port[1].to_i
                next if n < 1 || n > 65535
                rest = port.post_match
              end
              # path
              rest = skip_component(rest, PATH_CLOSERS) while rest[0] == "/"
              # query
              rest = skip_component(rest, QUERY_CLOSERS, QUERY_SEPARATORS) if rest[0] == '?'
              rest = skip_component(rest, FRAGMENT_CLOSERS, [], DIRECTIVE_SEPARATORS) if rest[0] == "#"
              rest_length = prefix.post_match.length - rest.length
              match_length = match.post_match.length - rest.length - scheme_offset
              next if @max_length && match_length > @max_length
              start = match.begin(0) + scheme_offset
              # Instead of +hn+, +host_raw+ is used to preseve original text
              result << {
                url: "#{proto}#{host_raw}#{prefix.post_match[...rest_length]}",
                indices: [start, start + match_length]
              }
            end
          rescue PublicSuffix::DomainInvalid
            # evidently we're not looking at the start of a link
          rescue PublicSuffix::DomainNotAllowed
            # ditto
          end
        end
      end
      # ah! the good feeling of going home after a hard day's work
      result
    end
  end
end
