class HomeController < ApplicationController
  def index
      @users = User.joins("LEFT JOIN groups_users ON user_id = users.id LEFT JOIN groups ON group_id = groups.id")
      @users = @users.select("users.name, users.created_at, count(groups.name) AS num_groups, string_agg(groups.name, ', ') AS groups_names")
      @users = @users.group("users.name, users.created_at")
  end
end
