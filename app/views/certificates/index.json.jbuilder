json.array!(@certificates) do |certificate|
  json.extract! certificate, :id, :keytext, :compromised
  json.url certificate_url(certificate, format: :json)
end
