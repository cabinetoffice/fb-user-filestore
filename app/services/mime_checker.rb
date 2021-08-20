class MimeChecker
  def initialize(value, whitelist)
    @value = value
    @whitelist = whitelist
  end

  def call
    return false if mime_type_invalid? || type.blank? || subtype.blank?

    whitelist.detect do |whitelisted|
      whitelisted_type, whitelisted_subtype = whitelisted.split('/')

      (whitelisted_type == "*" && whitelisted_subtype == "*") ||
      (type == whitelisted_type && whitelisted_subtype == "*") ||
      (type == whitelisted_type && subtype == whitelisted_subtype)
    end
  end

  def mime_type_invalid?
    MIME::Types[value][0].blank?
  end

  private

  def type
    @type ||= value.split('/')[0]
  end

  def subtype
    @subtype ||= value.split('/')[1]
  end

  attr_reader :value, :whitelist
end
