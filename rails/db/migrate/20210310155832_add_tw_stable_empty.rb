class AddTwStableEmpty < ActiveRecord::Migration[6.1]

  def up
    if Empty.where(name: 'tw5-stable').exists?
      say "tw5-stable empty exists already"

    else
      Empty.create!({
        name: 'tw5-stable',
        title: 'TiddlyWiki',
        description: 'The latest stable version of the current, modern version of TiddlyWiki, sometimes known as TiddlyWiki5.',
        enabled: true,
      })
      say "tw5-stable empty created"

    end
  end

  def down
    # Don't try to remove it just in case it's been used already.
    # Delete it manually if you really want to rerun this for some reason.
  end
end
