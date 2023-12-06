json.data do
  json.user_id @contract.user_id
  json.contract_number @contract.guid
  json.average_weekly_hours "#{@contract.average_weekly_hours}h"
  json.hourly_wage Money.from_cents(@contract.wage_cents, @contract.wage_currency).format(format: "%n%u")
  json.updated_at @contract.updated_at.iso8601
  json.created_at @contract.created_at.iso8601
end
