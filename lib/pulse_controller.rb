ActiveSupport::CoreExtensions::Module.class_eval do
  def alias_method_chain_unlink(target, feature) 
 
    # Strip out punctuation on predicates or bang methods since
    # e.g. target?_without_feature is not a valid method name.
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
    yield(aliased_target, punctuation) if block_given?
 
    with_method, without_method = "#{aliased_target}_with_#{feature}#{punctuation}", "#{aliased_target}_without_#{feature}#{punctuation}"
 
    alias_method target, without_method
 
    case
    when public_method_defined?(without_method)
      public target
    when protected_method_defined?(without_method)
      protected target
    when private_method_defined?(without_method)
      private target
    end
  end
end

ActionController::Base.class_eval do
  alias_method_chain_unlink :render, :passenger
  alias_method_chain_unlink :perform_action, :passenger
end

class PulseController < ActionController::Base
  session :off unless Rails::VERSION::STRING >= "2.3"

  #The pulse action. Runs <tt>select 1</tt> on the DB. If a sane result is
  #returned, 'OK' is displayed and a 200 response code is returned. If not,
  #'ERROR' is returned along with a 500 response code.
  def pulse
    if (ActiveRecord::Base::connection_pool.spec.adapter_method =~ /mysql2/) &&
      ((ActiveRecord::Base.connection.execute("select 1 from dual").count rescue 0) == 1)
      render :text => "<html><body>OK  #{Time.now.utc.to_s(:db)}</body></html>"
    elsif (ActiveRecord::Base.connection.execute("select 1 from dual").num_rows rescue 0) == 1
      render :text => "<html><body>OK  #{Time.now.utc.to_s(:db)}</body></html>"
    else
      render :text => '<html><body>ERROR</body></html>', :status => :internal_server_error
    end
  end
  
  def logger
    nil
  end
end
