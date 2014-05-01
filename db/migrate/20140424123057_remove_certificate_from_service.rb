class RemoveCertificateFromService < ActiveRecord::Migration
  def change
    remove_reference :services, :certificate, index: true
  end
end
