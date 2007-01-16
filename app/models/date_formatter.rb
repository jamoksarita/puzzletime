class DateFormatter
    
  def initialize(*date_fields)
    @date_fields = date_fields.collect {|f| f.to_s }
  end 
  
  def before_validation(model)
    @date_fields.each do |field|
      field_before_type_cast = model.send( field_symbol(field, '_before_type_cast') )
      if field_before_type_cast.kind_of? String
        begin
          model.send( field_symbol(field, '='), 
                      Date.strptime(field_before_type_cast, DATE_FORMAT) )
        rescue ArgumentError
          #invalid string, date will remain unaffected, i.e., nil
        end
      end  
    end 
  end
  
private
 
  def field_symbol(field, postfix)
    (field + postfix).to_sym
  end
  
end