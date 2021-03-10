class AddSortOrderToEmpties < ActiveRecord::Migration[6.1]

  def up
    add_column :empties, :sort_order, :integer, default: 0

    {
      'tw5' => 1,
      'tw5-stable' => 2,
      'classic' => 100,

    }.each do |empty_name, sort_order|
      say "#{empty_name} #{sort_order}"
      Empty.find_by_name(empty_name.to_s).try(:update!,{ sort_order: sort_order })
    end
  end

  def down
    remove_column :empties, :sort_order
  end

end
