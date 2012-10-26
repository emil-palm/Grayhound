require 'stringio'
module Grayhound
	class ProvisioningProfile < Grayhound::Base
		attr_accessor :uuid, :blob_id, :type, :name, :appid
		attr_accessor :xcode_status, :download_url, :data, :verification
		attr_accessor :raw_data

		def to_json(*a)
			{
				'uuid' => uuid,
				'type' => type,
				'name' => name,
				'appid' => appid,
				'statusXcode' => xcode_status
			}.to_json(*a)
		end

		def certificates(regex=nil)
			unless @certificates 
				@certificates = self.data['DeveloperCertificates'].map do |certificate_io|
					OpenSSL::X509::Certificate.new(certificate_io.string)
				end
			end
			unless regex
				@certificates
			else
				@certificates.select { |cert| cert.subject.to_a[1][1].match regex }
			end
		end

		def download_url=(url)
			@download_url = url
			self.raw_data = StringIO.new
			Grayhound::DeveloperCenter::agent.download(self.download_url, self.raw_data)
		end

		def data
			unless @data
				
				p7 = OpenSSL::PKCS7.new(raw_data.string)
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