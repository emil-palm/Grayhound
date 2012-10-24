module Grayhound
	class Certificate
		attr_accessor :displayId, :type, :name, :exp_date, :profiles, :status, :download_url, :data
		def to_json(*a)
			{
				'displayId' => displayId,
				'type' => type,
				'name' => name,
				'exp_date' => exp_date,
				'status' => status,
				'profiles' => profiles
			}.to_json(*a)
		end

		def ssl
			unless @data
				data = StringIO.new
				Grayhound::DeveloperCenter::agent.download(self.download_url, data)
				@data = OpenSSL::X509::Certificate.new(data.string)
			end
			@data
		end
	end
end