class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/batch_edit/preview')
    .description("Preview the results of a batch edit")
    .params(["repo_id", :repo_id],
            ["ref", String, "The resource to search"],
            ["record_type", String, "The record type to search"],
            ["property", String, "The property to replace"],
            ["find", String, "The string to find"],
            ["replace", String, "The string to replace"])
    .permissions([:update_resource_record])
    .returns([200, "OK"]) \
  do
    data = run_preview(params)

    json_response(data)
  end

  private

  def run_preview(params)
    parsed = JSONModel.parse_reference(params[:ref])
    base_record = Resource.get_or_die(parsed[:id])

    target_model = case params[:record_type]
    when 'date'
      ASDate
    else
      Kernel.const_get(params[:record_type].camelize)
    end

    target_property = params[:property]
    target_ids = base_record.object_graph.ids_for(target_model)

    find = params[:find] =~ /^\/.+\/$/ ? Regexp.new(params[:find][1..-2]) : params[:find]
    replace = params[:replace]

    results = []

    data = {
      'record_type' => params[:record_type],
      'property' => params[:property],
      'find' => find,
      'replace' => replace
    }

    target_ids.each do |id|
      json = target_model.to_jsonmodel(id)
      next unless json[target_property]

      result = json[target_property].gsub(find, replace)
      next if result == json[target_property]

      if json['uri'].nil?
        nested_model = target_model[id][:instance_id] ? Instance : target_model

        [:resource_id, :archival_object_id].each do |col|
          nesting_id = nested_model[id][col]
          if nesting_id
            nesting_model = Kernel.const_get(col.to_s[0..-4].camelize)
            json['uri'] = nesting_model[nesting_id].uri

            nested_parsed = JSONModel.parse_reference(json['uri'])
            nested_json = nesting_model.to_jsonmodel(nested_parsed[:id])
            ['title', 'component_id'].each{|k| json[k] = nested_json[k]}
          end
        end
      end

      results.push({
        'uri' => json['uri'],
        'title' => json['title'],
        'component_id' => json['component_id'],
        'old_value' => json[target_property],
        'new_value' => result
      })
    end

    data['results'] = results
    data

  end
end
