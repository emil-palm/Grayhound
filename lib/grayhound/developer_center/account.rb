module Grayhound
	module DeveloperCenter
		class Account
			class AccountException < Exception
			end

			module ModuleHook
				def self.included(base)
					base.send(:extend, ModuleMethods)
				end


				module ModuleMethods
					@@account = nil
					def account=(account)
						@@account = account
					end

					def setup_account(username,password,team={})
						self.account = Grayhound::DeveloperCenter::Account.new(username, password, team)
					end

					def account
						@@account
					end
				end
			end

			module ClassHook
				def load_page_or_login(url)
					page = Grayhound::DeveloperCenter::agent.get(url)
					state = Grayhound::DeveloperCenter::account.login_state(page)

					if state == :login
						Grayhound::DeveloperCenter::account.login(page)
						page = load_page_or_login(url)
					elsif state == :select_team
						Grayhound::DeveloperCenter::account.select_team(page)
						page = load_page_or_login(url)
					end

					return page
				end
			end

			attr_accessor :username, :password, :team_id, :team_name

			def initialize(username,password,team = {})
				self.username = username
				self.password = password
				self.team_id = team[:team_id]
				self.team_name = team[:team_name]

				raise AccountException("invalid arguments") unless self.username and self.password and (self.team_id or self.team_name)
			end

			def login_state (page)
				return :login if page.form_with(:name => 'appleConnectForm') != nil
				return :select_team if page.form_with(:name => 'saveTeamSelection') != nil
				return :ready
			end

			def login(page)

				page.form_with(:name => 'appleConnectForm') do |form|
					form.theAccountName = self.username
					form.theAccountPW = self.password
					form.submit

				end
			end

			def select_team(page)
				page.form_with(:name => 'saveTeamSelection') do |form|
					form.field_with(:name => 'memberDisplayId') do |team_list|
						if self.team_id
							team_option = team_list.option_with(:value => self.team_id)	
						elsif self.team_name
							team_option = team_list.option_with(:text => self.team_name)
						else
							team_option = team_list.options.first
						end

						team_option.select if team_option  
					end

					btn = form.button_with(:name => 'action:saveTeamSelection!save')
					return form.click_button(btn)
				end

				return page
			end


		end
	end
end

Grayhound::DeveloperCenter.send(:include, Grayhound::DeveloperCenter::Account::ModuleHook)
Grayhound::DeveloperCenter::Base.send(:include, Grayhound::DeveloperCenter::Account::ClassHook)