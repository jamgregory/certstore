json.array!(@services) do |service|
  json.extract! service, :id, :address, :hostname, :port, :certificate_id, :current
  json.url service_url(service, format: :json)
end
