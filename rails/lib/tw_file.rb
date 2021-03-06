
class TwFile

  def initialize(html_content)
    @doc = Nokogiri::HTML(html_content) do |config|
      config.options |= Nokogiri::XML::ParseOptions::HUGE
    end

    # Should be present for both TW5 and Classic
    @store = @doc.at_xpath("/html/body/div[@id='storeArea']")

    # Present for encrypted TW5 files only
    @encrypted_store = @doc.at_xpath("/html/body/pre[@id='encryptedStoreArea']")

    # Present for Classic only
    @shadow_store = @doc.at_xpath("/html/body/div[@id='shadowArea']")
  end

  def self.from_file(file_name)
    self.new(File.read(file_name))
  end

  # We can't be certain, but we can sanity check a few things to
  # confirm that it at least looks like a legitimate TiddlyWiki
  def looks_valid?
      # The application name is present
      tiddlywiki_title == 'TiddlyWiki' &&
        # Has one or other store divs but not both
        (store.present? ^ encrypted_store.present?) &&
        # We're able to extract a tiddlywiki version
        tiddlywiki_version.present?
  end

  def is_classic?
    tiddlywiki_version_classic.present?
  end

  def is_tw5?
    !is_classic?
  end

  def get_meta(name)
    doc.at_xpath("/html/head/meta[@name='#{name}']/@content").try(:to_s)
  end

  def tiddlywiki_version
    tiddlywiki_version_tw5 || tiddlywiki_version_classic
  end

  def tiddlywiki_title
    tiddlywiki_title_tw5 || tiddlywiki_title_classic
  end

  def tiddlywiki_version_tw5
    get_meta('tiddlywiki-version')
  end

  def tiddlywiki_title_tw5
    get_meta('application-name')
  end

  def tiddlywiki_version_area
    doc.at_xpath("/html/head/script[@id='versionArea']").presence
  end

  def tiddlywiki_version_classic
    match = tiddlywiki_version_area.try(:text).try(:match, /major: (\d+), minor: (\d+), revision: (\d+)/).presence
    "#{match[1]}.#{match[2]}.#{match[3]}" if match
  end

  def tiddlywiki_title_classic
    match = tiddlywiki_version_area.try(:text).try(:match, /title: "(\w+)"/).presence
    match[1] if match
  end

  def encrypted?
    encrypted_store.present?
  end

  def to_html
    doc.to_html
  end

  # ** Methods from here down are useless for encrypted TiddlyWikis **

  def write_tiddlers(tiddlers, shadow=false)
    tiddlers.each do |title, data|
      insert_or_replace(title, data, shadow)
    end

    # For chaining method calls
    self
  end

  def write_shadow_tiddlers(tiddlers)
    write_tiddlers(tiddlers, true)
  end

  def tiddler_content(title, shadow=false)
    tiddler(title, shadow).try(:at_xpath, 'pre').try(:content)
  end

  def shadow_tiddler_content(title)
    tiddler_content(title, true)
  end

  private

  attr_reader :doc, :store, :encrypted_store, :shadow_store

  def insert_or_replace(title, data, shadow)
    return if encrypted?

    tiddler_div = create_tiddler_div(title, data)

    if existing_tiddler = tiddler(title, shadow)
      existing_tiddler.replace(tiddler_div)
    else
      (shadow ? shadow_store : store) << tiddler_div
    end
  end

  def tiddler(title, shadow=false)
    return if encrypted?

    # TODO: See how this works for titles with quotes in them
    tiddler_divs = (shadow ? shadow_store : store).xpath("div[@title='#{title}']")
    raise 'Multiple tiddlers found!' if tiddler_divs.length > 1
    tiddler_divs.first
  end

  def shadow_tiddler(title)
    tiddler(title, true)
  end

  # We can return a string like this and it works fine:
  #   %{<div title="#{title}"><pre>#{content}</pre></div>}
  #
  # Doing it this way because I expect Nokogiri knows
  # better than I do how to do the escaping.
  #
  def create_tiddler_div(title, data)
    data = { content: data } if data.is_a?(String)

    div = new_node('div')
    pre = div.add_child(new_node('pre'))
    div['title'] = title
    pre.content = data.delete(:content) || ''

    # For attributes like tags, modifier, etc
    data.each do |attr_name, attr_value|
      div[attr_name.to_s] = attr_value
    end

    div
  end

  def new_node(elem_name)
    Nokogiri::XML::Node.new(elem_name, doc)
  end

end
