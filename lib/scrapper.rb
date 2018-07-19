require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'


class Scrapper
	attr_accessor :townhalls_emails, :townhalls_names 
	
	def initialize
		@townhalls_names = townhalls_names
		@townhalls_emails = townhalls_emails
	end

	def get_the_email_of_a_townhal_from_its_webpage                                                             # Récupère l'adresse e-mail d'une mairie sur sa homepage
	    Nokogiri::HTML(open(@url_townhall_temp)).css('section[2] tr[4] td[2]').text
	end

	def get_all_the_urls_of_val_doise_townhalls
	    url_townhalls = []
	    @townhalls_names = []
	    @townhalls_emails = []
	    @@townhalls_names_emails = []
	    
	    Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html")).css('.lientxt').each do |town|    # Récupère les noms et les adresses url des mairies du 95 et les stocke dans des arrays
	        url_townhalls << "http://annuaire-des-mairies.com/95/#{town.text.downcase.gsub(" ","-")}.html"      
	        @townhalls_names << town.text.downcase.gsub(" ","-")
	    end

	    url_townhalls.each do |url_townhall|
	        @url_townhall_temp = url_townhall
	        @townhalls_emails << get_the_email_of_a_townhal_from_its_webpage                                       # Récupère les adresses e-mail des mairies et les stocke dans un arrray
	    end

	    @townhalls_names.each_with_index do |townhall_name, i|
	        hash_temp = {}
	        hash_temp["name"] = @townhalls_names[i]
	        hash_temp["email"] = @townhalls_emails[i]
	        @@townhalls_names_emails << hash_temp                                                                   # Combine les arrays des noms de mairies et leurs e-mails en un hash                    
	    end

	    return @@townhalls_names_emails
	    
	end

	def create_csv(array_to_push)
		CSV.open("db/townhalls_names_emails_listing.csv", "wb") do |csv_file|
			csv_file << array_to_push.first.keys
			array_to_push.each do |the_hash|
				csv_file << the_hash.values
			end
		end
	end

	def perform
		create_csv(get_all_the_urls_of_val_doise_townhalls)
	end

end


