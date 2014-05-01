class MoveServiceDataToScan < ActiveRecord::Migration
  def change
    reversible do |dir|
      all_services=Service.all
      distinct_services=all_services.map { |service| { hostname: service.hostname, address: service.address, port: service.port }}
      dir.up do
        Service.select(:hostname, :address, :port).distinct.each do |service|
          service_entries=Service.where(hostname: service.hostname, address: service.address, port: service.port)
          first_service_entry=service_entries.first
          
          service_entries.each do |service_entry| 
            Scan.create(service: first_service_entry, 
                        certificate_id: service_entry.certificate_id, 
                        state: :completed, 
                        message: 'Completed',
                        created_at: service_entry.created_at,
                        updated_at: service_entry.updated_at)
            Rails.logger.info "Migrated Service to Scan for Service #{service_entry.id}"
          end
          Rails.logger.debug "Found First Service ID #{first_service_entry.id}"
          service_ids=service_entries.map { |x| x.id }
          service_ids_to_delete=service_ids.reject {|x| x==first_service_entry.id }
          Rails.logger.info "Removing Service IDs #{service_ids_to_delete.join(" ")}"
          Service.where(id: service_ids_to_delete).delete_all
        end
      end
      dir.down do
      end
    end
  end
end
