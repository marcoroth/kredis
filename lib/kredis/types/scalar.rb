class Kredis::Types::Scalar < Kredis::Types::Proxying
  proxying :set, :get, :exists?, :del, :expire, :expireat

  attr_accessor :typed, :default, :expires_in

  def initialize(...)
    super

    if !exists? && default.present?
      self.value = default_value
    end
  end

  def value=(value)
    set type_to_string(value, typed), ex: expires_in
  end

  def value
    value_after_casting = string_to_type(get, typed)

    if value_after_casting.nil?
      default_value
    else
      value_after_casting
    end
  end

  def default_value
    default.is_a?(Proc) ? default.call : default
  end

  def to_s
    get || default_value&.to_s
  end

  def assigned?
    exists?
  end

  def clear
    del
  end

  def expire_in(seconds)
    expire seconds.to_i
  end

  def expire_at(datetime)
    expireat datetime.to_i
  end
end
