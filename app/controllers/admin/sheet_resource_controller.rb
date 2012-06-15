class Admin::SheetResourceController < Admin::ResourceController
  paginate_models
  # only_allow_access_to must be set
  
  prepend_before_filter :find_root
  prepend_before_filter :create_root, :only => [:new, :upload]
  
  def upload
    if params[:upload].blank?  # necessary params are missing
      render :text => '', :status => :bad_request
    else
      @sheet = model_class.create_or_update_from_upload!(params[:upload][:upload])
      if @sheet.new_record?
        response_for :create
      else
        slug = params[:upload][:upload].original_filename.to_slug().gsub(/-dot-css$/,'.css').gsub(/-js/,'.js')
        flash[:notice] = "#{slug} was succesfully overwritten."
        response_for :update
      end
    end
  end
  
  def new
    self.model = model_class.new_with_defaults
    response_for :new
  end
  
  def create
    model.parent_id = @root.id
    model.update_attributes!(params[model_symbol])
    response_for :create
  end
  
  private
  
  def load_models
    @root.try(:children) || []
  end
  
  def find_root
    @root = model_class.root
  rescue Page::MissingRootPageError, Sheet::InvalidHomePage => e
    flash[:error] = t('sheets.root_required', :model => humanized_model_name)
    redirect_to welcome_path and return false
  end
  
  def create_root
    unless @root
      begin
        model_class.create_root
      rescue Page::MissingRootPageError
        flash[:error] = t('sheets.root_required', :model => humanized_model_name)
        redirect_to welcome_path and return false
      end
    end
  end
end
