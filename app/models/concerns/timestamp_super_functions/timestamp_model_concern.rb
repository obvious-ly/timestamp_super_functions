# we use timestamps instead of booleans throughout this project
# this module make timestamps behave like booleans anyway
module TimestampSuperFunctions
  module TimestampModelConcern
    extend ActiveSupport::Concern
    included do
      def self.add_timestamp_helper_functions(list)
        list.uniq.collect(&:to_s).each{|method_name|
          
          if method_name.ends_with?("_at")
            # boolean setting timestamp as now, e.g contract_signed = true => contract_signed_at = Time.now
            define_method "#{method_name[0...(method_name.length - 3)]}=" do |val|
                if val == "true" || val == 1  || val == "1" || val == true
                  self.send("#{method_name}=", Time.now) if self.send(method_name).nil?
                else
                  self.send("#{method_name}=", nil)
                end
            end
            
            # boolean for presence, e.g contract_signed? => !contract_signed_at.nil?
            define_method "#{method_name[0...(method_name.length - 3)]}?" do
                !self.send(method_name).nil?
            end
            
            define_method "#{method_name[0...(method_name.length - 3)]}" do
                !self.send(method_name).nil?
            end
            
            # boolean for presence, e.g not_contract_signed? => contract_signed_at.nil?
            define_method "not_#{method_name[0...(method_name.length - 3)]}?" do
                self.send(method_name).nil?
            end
            
            define_method "not_#{method_name[0...(method_name.length - 3)]}" do
                self.send(method_name).nil?
            end

            #scopes e.g Contract.contract_signed => where("contract_signed_at is not null")
            self.class.send(:define_method, "#{method_name[0...(method_name.length - 3)]}") do
              where("#{self.table_name}.#{method_name} is not null")
            end
            self.class.send(:define_method, "not_#{method_name[0...(method_name.length - 3)]}") do
              where("#{self.table_name}.#{method_name} is null")
            end
            
          end
        }
      end
    end
  end
end