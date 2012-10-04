module StylesheetTags
  include Radiant::Taggable
  class TagError < StandardError; end
  
  desc %{
Renders the content from or a reference to the stylesheet specified in the @slug@ 
attribute. Additionally, the @as@ attribute can be used to make the tag render 
as one of the following:

* with no @as@ value the stylesheet's content is rendered by default.
* @inline@ - wraps the stylesheet's content in an (X)HTML @<style>@ element.
* @path@ - the full path to the stylesheet.
* @link@ - embeds the url in an (X)HTML @<link>@ element (creating a link to the external stylesheet).

*Additional Options:*
When rendering @as="inline"@ or @as="link"@, the (X)HTML @type@ attribute
is automatically be set to the default stylesheet content-type.
You can overrride this attribute or add additional ones by passing extra
attributes to the @<r:stylesheet>@ tag.
      
*Usage:*
      
<pre><code><r:stylesheet slug="site.css" as="inline" 
  type="text/custom" id="my_id" />
<r:stylesheet slug="other.css" as="link" 
  rel="alternate stylesheet" /></code></pre>

The above example will produce the following:
      
<pre><code>        <style type="text/custom" id="my_id">
/*<![CDATA[*/
  .your_stylesheet { content: 'here' }
/*]]>*/
</style>
<link rel="alternate stylesheet" type="text/css" 
  href="/css/other.css" /></code></pre>
  }
  tag 'stylesheet' do |tag|
    slug = (tag.attr['slug'] || tag.attr['name'])
    raise TagError.new("`stylesheet' tag must contain a `slug' attribute.") unless slug
    if (stylesheet = StylesheetPage.find_by_slug(slug))
      mime_type = tag.attr['type'] || stylesheet.headers['Content-Type']
      path = stylesheet.path
      rel = tag.attr.delete('rel') || 'stylesheet'
      optional_attributes = tag.attr.except('slug', 'name', 'as', 'type').inject('') { |s, (k, v)| s << %{#{k}="#{v}" } }.strip
      optional_attributes = " #{optional_attributes}" unless optional_attributes.empty?
      asset_host = (Radiant::Config['sheets.asset_host'] ? Radiant::Config['sheets.asset_host'] : '')
      case tag.attr['as']
      when 'url','path'
        asset_host+path
      when 'inline'
        %{<style type="#{mime_type}"#{optional_attributes}>\n/*<![CDATA[*/\n#{stylesheet.render_part('body')}\n/*]]>*/\n</style>}
      when 'link'
        %{<link rel="#{rel}" type="#{mime_type}" href="#{asset_host}#{path}"#{optional_attributes} />}
      else
        stylesheet.render_part('body')
      end
    else
      raise TagError.new("stylesheet #{slug} not found")
    end
  end
end
