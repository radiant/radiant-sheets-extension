# Uncomment this if you reference any of your controllers in activate
require_dependency 'application_controller'
require 'compass'
require 'radiant-sheets-extension/version'

class SheetsExtension < Radiant::Extension
  version RadiantSheetsExtension::VERSION
  description "Manage CSS and Javascript content in Radiant CMS as Sheets, a subset of Pages"
  url "http://github.com/radiant/radiant"
  
  cattr_accessor :stylesheet_filters
  cattr_accessor :javascript_filters
  
  @@stylesheet_filters ||= []
  @@stylesheet_filters += [SassFilter, ScssFilter]
  @@javascript_filters ||= []
  
  begin
    @@javascript_filters << CoffeeFilter
  rescue ExecJS::RuntimeUnavailable
    Rails.logger.warn "There is no support for CoffeeScript"
  end
  
  def activate
    MenuRenderer.exclude 'JavascriptPage', 'StylesheetPage'
    
    tab 'Design' do
      add_item "Stylesheets", "/admin/styles"
      add_item "Javascripts", "/admin/scripts"
    end
    
    ApplicationHelper.module_eval do
      def filter_options_for_select_with_sheet_restrictions(selected=nil)
        sheet_filters = SheetsExtension.stylesheet_filters + SheetsExtension.javascript_filters
        filters = TextFilter.descendants - sheet_filters
        options_for_select([[t('select.none'), '']] + filters.map { |s| s.filter_name }.sort, selected)
      end
      alias_method_chain :filter_options_for_select, :sheet_restrictions
    end
    
    Page.class_eval do      
      def sheet?
        self.is_a?(Sheet::Instance)
      end

      include JavascriptTags
      include StylesheetTags
    end
    
    Admin::NodeHelper.module_eval do
      def render_node_with_sheets(page, locals = {})
        unless page.sheet?
          render_node_without_sheets(page, locals)
        end
      end
      alias_method_chain :render_node, :sheets
    end
  end
end
