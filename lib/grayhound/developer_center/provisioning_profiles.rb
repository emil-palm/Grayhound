module Grayhound
	module DeveloperCenter

		DEVELOPMENT_PROFILES_URL = "https://developer.apple.com/ios/my/provision/index.action"
		DISTRIBUTION_PROFILES_URL = "https://developer.apple.com/ios/my/provisioningprofiles/viewDistributionProfiles.action"

		class ProvisioningProfiles < Grayhound::DeveloperCenter::Base
			include Enumerable
			module Hook
				def self.included(base)
					base.send(:extend, ModuleMethods)
				end

				module ModuleMethods
					@@prov_profiles = nil

					def profiles
						unless @@prov_profiles
							@@prov_profiles = Grayhound::DeveloperCenter::ProvisioningProfiles.new
						end
						@@prov_profiles
					end

					@@verify_provisioning_profiles = false

					def verify_provisioning_profiles?
						@@verify_provisioning_profiles
					end

					def verify_provisioning_profiles=(verify)
						@@verify_provisioning_profiles = verify
					end
				end
			end

			attr_reader :development, :distribution

			def each
				(self.development + self.distribution).each { |pp| yield pp }
			end

			def development
				unless @development
					load_development_profiles
				end
				@development
			end

			def distribution
				unless @distribution
					load_distribution_profiles
				end
				@distribution
			end

			def each_development
				unless @development_profiles 
					load_development_profiles
				end

				@development_profiles.each { |p| yield p }
			end

			def each_distribution
				unless @distribution_profiles
					load_distribution_profiles
				end
				@distribution_profiles.each { |p| yield p }
			end

			def load_development_profiles
				self.load_page_or_login(Grayhound::DeveloperCenter::DEVELOPMENT_PROFILES_URL).tap do |page|
					@development = [].tap do |array|
						parse_profiles_page(page) do |p|
							p.type = :development
							array << p
						end
					end
				end
			end

			def load_distribution_profiles
				self.load_page_or_login(Grayhound::DeveloperCenter::DISTRIBUTION_PROFILES_URL).tap do |page|
					@distribution = [].tap do |array|
						parse_profiles_page(page) do |p|
							p.type = :distribution
							array << p
						end
					end
				end
			end

			protected

			def parse_profiles_page(page)
				rows = page.parser.xpath('//table/tbody/tr').each do |row|
					p = Grayhound::ProvisioningProfile.new()
					# p.blob_id = row.at_xpath('td[@class="checkbox"]/input/@value').to_s
					next if row.at_xpath('td[@class="profile"]/a').nil?
					p.name = row.at_xpath('td[@class="profile"]/a').text.to_s
					p.appid = row.at_xpath('td[@class="appid"]/text()').to_s
					p.xcode_status = row.at_xpath('td[@class="statusXcode"]').text.strip.split("\n")[0].to_s
					p.download_url = row.at_xpath('td[@class="action"]/a/@href').to_s
					yield p
				end
			end
		end
	end
end

Grayhound::DeveloperCenter.send(:include, Grayhound::DeveloperCenter::ProvisioningProfiles::Hook)