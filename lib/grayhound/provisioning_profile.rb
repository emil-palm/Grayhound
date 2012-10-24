require 'stringio'
module Grayhound
	class ProvisioningProfile
		attr_accessor :uuid, :blob_id, :type, :name, :appid
		attr_accessor :xcode_status, :download_url, :data, :verification

		def to_json(*a)
			{
				'uuid' => uuid,
				'type' => type,
				'name' => name,
				'appid' => appid,
				'statusXcode' => xcode_status
			}.to_json(*a)
		end

		def certificates
			unless @certificates 
				@certificates = self.data['DeveloperCertificates'].map do |certificate_io|
					OpenSSL::X509::Certificate.new(certificate_io.string)
				end
			end
			@certificates
		end

		def data
			unless @data
				data = StringIO.new
				Grayhound::DeveloperCenter::agent.download(self.download_url, data)
				p7 = OpenSSL::PKCS7.new(data.string)
				store = OpenSSL::X509::Store.new
				if Grayhound::DeveloperCenter::verify_provisioning_profiles?
					cert = OpenSSL::X509::Certificate.new(Grayhound::DeveloperCenter::apple_certificate.read())
					store.add_cert cert
					self.verification = p7.verify [cert], store
				else
					p7.verify [], store
					self.verification = nil
				end

				if Grayhound::DeveloperCenter::verify_provisioning_profiles? and self.verification
					@data = Plist::parse_xml(p7.data)
				elsif Grayhound::DeveloperCenter::verify_provisioning_profiles? == false
					@data = Plist::parse_xml(p7.data)
				end	
			end
			@data
		end
	end
end