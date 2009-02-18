module Account::EventsExtension
  
  def import(data, options={})
    importer = Event::Importer.new(proxy_owner)
    importer.import(data,options)
  end
  
end