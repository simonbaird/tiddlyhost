
require 'aws-sdk-s3'

class Tiddlyspot::SiteFetcher

  def initialize(site_name, secrets=nil)
    secrets ||= Settings.secrets(:dreamobjects)
    @site_name = site_name
    @bucket_name = secrets[:bucket_name]
    @s3_client = Aws::S3::Client.new(
      endpoint: secrets[:endpoint_url],
      region: secrets[:region],
      access_key_id: secrets[:aws_server_public_key],
      secret_access_key: secrets[:aws_server_secret_key])
  end

  def html_file
    @_html ||= site_file('index.html')
  end

  def htpasswd_file
    @_htpasswd ||= site_file('.htpasswd')
  end

  def htaccess_file
    @_htaccess ||= site_file('.htaccess')
  end

  def htmeta_file
    @_htmeta ||= site_file('.htmeta')
  end

  def passwd_ok?(given_passwd)
    return unless given_passwd.present? && htpasswd_file.present?
    salt = @site_name[0,2]
    passwd_crypt = htpasswd_file.split(':').last
    given_passwd.crypt(salt) == passwd_crypt
  end

  private

  def site_file(file_name)
    fetch_key(site_key(file_name))
  end

  def site_key(file_name)
    exploded_path = "#{@site_name[0,1]}/#{@site_name[0,2]}/#{@site_name[0,3]}/#{@site_name}"
    "ts/sites/#{exploded_path}/#{file_name}"
  end

  def fetch_key(key)
    begin
      object = @s3_client.get_object(bucket: @bucket_name, key: key).body.read
    rescue Aws::S3::Errors::NoSuchKey
      nil
    end
  end

end
