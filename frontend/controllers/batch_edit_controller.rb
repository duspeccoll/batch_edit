class BatchEditController < ApplicationController

  set_access_control "update_resource_record" => [:index, :preview]

  def index
    @edit = {}

    flash[:alert] = "This is an interface proof of concept only; it will not make changes to your database."
  end

  def preview
    data = params['batch_edit']
    data = ASUtils.recursive_reject_key(data) { |k| k === '_resolved' }

    @data = run_preview(data)
  end

  private

  def run_preview(data)
    data.each{|k,v| params[k] = v}
    response = JSONModel::HTTP::post_form("/repositories/#{session[:repo_id]}/batch_edit/preview", params)

    json = ASUtils.json_parse(response.body)

    if response.code != '200'
      flash[:error] = json['error']
      redirect_to request.referer
    else
      json
    end
  end
end
