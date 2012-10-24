module Grayhound
	module DeveloperCenter
		DEVELOPMENT_CERTIFICATES_URL = "https://developer.apple.com/ios/manage/certificates/team/index.action"
		DISTRIBUTION_CERTIFICATES_URL = "https://developer.apple.com/ios/manage/certificates/team/distribute.action"

		class Certificates < Grayhound::DeveloperCenter::Base
			module Hook
				def self.included(base)
					base.send(:extend, ModuleMethods)
				end

				module ModuleMethods
					@@certificates = nil

					def certificates
						unless @@certificates
							@@certificates = Grayhound::DeveloperCenter::Certificates.new
						end
						@@certificates
					end
				end
			end

			attr_reader :development, :distribution

			def development
				unless @development
					load_development_certificates
				end
				@development
			end

			def distribution
				unless @distribution
					load_distribution_certificates
				end
				@distribution
			end

			def load_development_certificates
				self.load_page_or_login(Grayhound::DeveloperCenter::DEVELOPMENT_CERTIFICATES_URL).tap do |page|
					@development = [].tap do |array|
						page.parser.xpath('//div[@class="nt_multi"]/table/tbody/tr').each do |row|
							last_elt = row.at_xpath('td[@class="last"]')
							next if last_elt.at_xpath('form').nil?
							c = Grayhound::Certificate.new()

							c.download_url = last_elt.at_xpath('a/@href').to_s
							c.displayId = c.download_url.to_s.split("certDisplayId=")[1].to_s
							c.type = :development
							c.name = row.at_xpath('td[@class="name"]/div/p').text.to_s
							c.exp_date = row.at_xpath('td[@class="date"]').text.strip.to_s


							c.profiles = [].tap do |array|
								row.xpath('td[@class="profiles"]/div/div/text()').each do |x|
									array << x.text.strip
								end
							end
							
							c.status = row.at_xpath('td[@class="status"]').text.strip.to_s
							array << c
						end
					end
				end
			end

			def load_distribution_certificates
				self.load_page_or_login(Grayhound::DeveloperCenter::DISTRIBUTION_CERTIFICATES_URL).tap do |page|
					@distribution = [].tap do |array|
						page.parser.xpath('//div[@class="nt_multi"]/table/tbody/tr').each do |row|
							last_elt = row.at_xpath('td[@class="action last"]')
							if last_elt.nil?
								msg_elt = row.at_xpath('td[@colspan="4"]/span')
								next
							end

							next if last_elt.at_xpath('form').nil?
							c = Grayhound::Certificate.new()

							c.download_url = last_elt.at_xpath('a/@href').to_s
							c.displayId = c.download_url.to_s.split("certDisplayId=")[1].to_s
							c.type = :distribution
							c.name = row.at_xpath('td[@class="name"]/a').text.to_s
							c.exp_date = row.at_xpath('td[@class="expdate"]').text.strip.to_s
							c.profiles = row.at_xpath('td[@class="profile"]').text.strip.to_s
							c.status = row.at_xpath('td[@class="status"]').text.strip.to_s
							array << c
						end
					end
				end
			end
		end
	end
end

Grayhound::DeveloperCenter.send(:include, Grayhound::DeveloperCenter::Certificates::Hook)