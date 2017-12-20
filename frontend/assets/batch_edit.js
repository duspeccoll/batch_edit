$(function() {

  var initBatchEditForm = function() {
    var $form = $('#batch_edit');

    $(".btn:submit", $form).on("click", function(event) {
      event.stopPropagation();
      event.preventDefault();
      $form.submit();
    });

    $(document).ready(function() {
      $(".linker:not(.initialised)").linker();

      var $selectRecordType = $("#batch_edit_record_type_");
      var $selectProperty = $("#batch_edit_property_");
      $selectRecordType.attr('disabled', 'disabled');
      $selectProperty.attr('disabled', 'disabled');

      $("#batch_edit_ref_").change(function() {
        var resourceUri = $(this).val();
        if (resourceUri.length) {
          var id = /\d+$/.exec(resourceUri)[0]
          $.ajax({
            url: AS.app_prefix("/resources/" + id + "/models_in_graph"),
            success: function(typeList) {
              var oldVal = $selectRecordType.val();
              $selectRecordType.empty();
              $selectRecordType.append($('<option>', {selected: true, disabled: true})
                .text(" -- select a record type --"));
              $.each(typeList, function(index, valAndText) {
                var opts = { value: valAndText[0]};
                if (oldVal === valAndText[0])
                  opts.selected = true;

                $selectRecordType.append($('<option>', opts)
                                         .text(valAndText[1]));
              });
              $selectRecordType.removeAttr('disabled');
              if (oldVal != $selectRecordType.val())
                $selectRecordType.triggerHandler('change');
            }
          });
        }
      });

      $selectRecordType.change(function() {
        var recordType = $(this).val();
        $.ajax({
          url: AS.app_prefix("/schema/" + recordType + "/properties?type=string&editable=true"),
          success : function(propertyList) {
            $selectProperty.empty();

            $.each(propertyList, function(index, valAndText) {
              $selectProperty
                .append($('<option>', { value: valAndText[0] })
                        .text(valAndText[1]));
            });

            $selectProperty.removeAttr('disabled');
          }
        });
      });
    });
  };

  initBatchEditForm();
});
