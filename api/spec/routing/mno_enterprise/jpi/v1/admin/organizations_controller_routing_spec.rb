require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::OrganizationsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/organizations')).to route_to("mno_enterprise/jpi/v1/admin/organizations#index", format: "json")
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/admin/organizations/1')).to route_to("mno_enterprise/jpi/v1/admin/organizations#show", format: "json", id: '1')
    end

    it 'routes to #in_arrears' do
      expect(get('/jpi/v1/admin/organizations/in_arrears')).to route_to("mno_enterprise/jpi/v1/admin/organizations#in_arrears", format: "json")
    end
  end
end

