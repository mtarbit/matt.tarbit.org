class FormRowBuilder < ActionView::Helpers::FormBuilder

  def self.create_method_for_field(field_name)
    define_method(field_name) do |field, *args|
      label = args[0].delete(:label) || field.to_s.humanize
      label = @template.content_tag(:label, label + ":", :for => "#{@object_name}_#{field}")
      input = super(field, *args)

      @template.content_tag(:div,
        @template.content_tag(:div, label, :class=>'label') +
        @template.content_tag(:div, input, :class=>'input'),
      :class=>'form-row')
    end
  end

  field_helpers.each do |name|
    create_method_for_field(name)
  end
end
