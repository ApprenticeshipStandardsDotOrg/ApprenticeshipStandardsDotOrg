module Admin
  class UsersController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   super
    #   send_foo_updated_email(requested_resource)
    # end
    #
    def create
      resource = resource_class.new(resource_params)
      authorize_resource(resource)

      resource.password = resource.password_confirmation = SecureRandom.hex(User::DEFAULT_PASSWORD_LENGTH)
      if resource.save
        resource.invite!
        redirect_to(
          after_resource_created_path(resource),
          notice: translate_with_resource("create.success")
        )
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, resource)
        }, status: :unprocessable_content
      end
    end

    def invite
      invitation = requested_resource.invite!
      resource_invited = invitation.errors.empty?

      if resource_invited
        flash[:notice] = I18n.t("devise.invitations.send_instructions", email: requested_resource.email)
      else
        flash[:error] = "There was an error trying to send an invite to this user"
      end
      redirect_to admin_user_path(requested_resource)
    end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # The result of this lookup will be available as `requested_resource`

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    # def scoped_resource
    #   if current_user.super_admin?
    #     resource_class
    #   else
    #     resource_class.with_less_stuff
    #   end
    # end
    def scoped_resource
      User.includes(:api_keys)
    end

    # Override `resource_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `resource_class`
    # and `dashboard`:
    #
    # def resource_params
    #   params.require(resource_class.model_name.param_key).
    #     permit(dashboard.permitted_attributes).
    #     transform_values { |value| value == "" ? nil : value }
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
