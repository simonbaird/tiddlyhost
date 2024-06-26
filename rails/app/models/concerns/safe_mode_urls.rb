# frozen_string_literal: true

module SafeModeUrls
  extend ActiveSupport::Concern

  TW5_SUFFIX = "#:safe".freeze
  CLASSIC_SUFFIX = "#start:safe".freeze

  def safe_mode_url
    case tw_kind
    when "tw5", "tw5x"
      url + TW5_SUFFIX

    when "classic"
      # Beware that classic in safe mode can't save because
      # the ThostUploadPlugin will be disabled
      url + CLASSIC_SUFFIX

    else
      # Let's not try to handle the edge case of
      # older sites that don't have a tw_kind
      nil

    end
  end

end
