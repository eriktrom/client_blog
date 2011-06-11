xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @google.page_title
    xml.description @google.meta_desc
    xml.link posts_index_url(:atom)
    
    collection.each do |resource|
      xml.item do
        xml.title resource.page_title
        xml.description resource.body
        xml.pubDate resource.created_at.to_s(:rfc822)
        xml.link post_show_url(resource, :atom)
        xml.guid post_show_url(resource, :atom)
      end
    end
  end
end