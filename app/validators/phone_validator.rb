# Validates phone format
class PhoneValidator < ActiveModel::Validator
  def validate(record)
    if record.phone_number.present?
      # if only the international digits are set, do nothing, these are set by default from the input
      if record.phone_number.length > 4 && record.phone_number.match?(/\A\+\d{1,3}\d{10}\z/i)
        true
      elsif record.phone_number.length < 4
        true
      else
        record.errors.add :base, I18n.t("validations.only_numbers_for_phone")
      end
    end
  end
end
