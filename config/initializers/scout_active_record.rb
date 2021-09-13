if defined?(ScoutApm)
  module ScoutApm
    module Instruments
      module ActiveRecordQueryingInstruments
        alias _find_by_sql_with_scout_instruments find_by_sql_with_scout_instruments
        def find_by_sql_with_scout_instruments(**args, &block)
          _find_by_sql_with_scout_instruments(*args, &block)
        end
      end
    end
  end
end
