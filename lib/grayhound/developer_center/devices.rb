module Grayhound
	module DeveloperCenter
		DEVICES_URL = "https://developer.apple.com/ios/manage/devices/index.action"
		
		class Devices < Grayhound::DeveloperCenter::Base

			module Hook
				def self.included(base)
					base.send(:extend, ModuleMethods)
				end

				module ModuleMethods
					@@devices = nil

					def devices
						unless @@devices
							@@devices = Grayhound::DeveloperCenter::Devices.new
						end
						@@devices
					end
				end
			end

			include Enumerable

			def initialize()
				@devices = nil
			end

			def each 
				unless @devices
					load_devices
				end
				@devices.each { |d| yield d }
			end

			def load_devices
				self.load_page_or_login(Grayhound::DeveloperCenter::DEVICES_URL).tap do |page|
					@devices = [].tap do |array|
						rows = page.parser.xpath('//fieldset[@id="fs-0"]/table/tbody/tr')
						rows.each do |row|
							d = Grayhound::Device.new()
							d.name = row.at_xpath('td[@class="name"]/span/text()').to_s
							d.udid = row.at_xpath('td[@class="id"]/text()').to_s
							array << d
						end
					end
				end
			end
		end
	end
end

Grayhound::DeveloperCenter.send(:include, Grayhound::DeveloperCenter::Devices::Hook)
