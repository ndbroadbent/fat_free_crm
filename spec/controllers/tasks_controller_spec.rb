require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TasksController do

  def get_data_for_sidebar
    @task_total = Task.stub!(:totals).and_return({ :key => :value })
  end

  before(:each) do
    require_user
    set_current_tab(:tasks)
    @uuid = "12345678-0123-5678-0123-567890123456"
  end

  def mock_task(stubs={})
    @mock_task ||= mock_model(Task, stubs)
  end
  
  describe "responding to GET index" do

    before(:each) do
      get_data_for_sidebar
    end

    it "should expose all tasks as @tasks" do
      Task.should_receive(:list).and_return([mock_task])
      Setting.should_receive(:task_due_date).and_return([[ "key", :value ]])
      Setting.should_receive(:task_category).and_return({ :key => :value })
      User.should_receive(:all_except).with(@current_user) if @view == "assigned"
      get :index
      assigns[:tasks].should == [mock_task]
    end

    describe "with mime type of xml" do
  
      it "should render all tasks as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Task.should_receive(:list).and_return(tasks = mock("Array of Tasks"))
        Setting.should_receive(:task_due_date).and_return([[ "key", :value ]])
        Setting.should_receive(:task_category).and_return({ :key => :value })
        User.should_receive(:all_except).with(@current_user) if @view == "assigned"
        tasks.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested task as @task" do
      Task.should_receive(:find).with("37").and_return(mock_task)
      get :show, :id => "37"
      assigns[:task].should equal(mock_task)
    end
    
    describe "with mime type of xml" do

      it "should render the requested task as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Task.should_receive(:find).with("37").and_return(mock_task)
        mock_task.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new task as @task" do
      Task.should_receive(:new).and_return(mock_task)
      get :new
      assigns[:task].should equal(mock_task)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested task as @task" do
      Task.should_receive(:find).with("37").and_return(mock_task)
      get :edit, :id => "37"
      assigns[:task].should equal(mock_task)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created task as @task" do
        Task.should_receive(:new).with({'these' => 'params'}).and_return(mock_task(:save => true))
        post :create, :task => {:these => 'params'}
        assigns(:task).should equal(mock_task)
      end

      it "should redirect to the created task" do
        Task.stub!(:new).and_return(mock_task(:save => true))
        post :create, :task => {}
        response.should redirect_to(task_url(mock_task))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved task as @task" do
        Task.stub!(:new).with({'these' => 'params'}).and_return(mock_task(:save => false))
        post :create, :task => {:these => 'params'}
        assigns(:task).should equal(mock_task)
      end

      it "should re-render the 'new' template" do
        Task.stub!(:new).and_return(mock_task(:save => false))
        post :create, :task => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested task" do
        Task.should_receive(:find).with("37").and_return(mock_task)
        mock_task.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :task => {:these => 'params'}
      end

      it "should expose the requested task as @task" do
        Task.stub!(:find).and_return(mock_task(:update_attributes => true))
        put :update, :id => "1"
        assigns(:task).should equal(mock_task)
      end

      it "should redirect to the task" do
        Task.stub!(:find).and_return(mock_task(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(task_url(mock_task))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested task" do
        Task.should_receive(:find).with("37").and_return(mock_task)
        mock_task.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :task => {:these => 'params'}
      end

      it "should expose the task as @task" do
        Task.stub!(:find).and_return(mock_task(:update_attributes => false))
        put :update, :id => "1"
        assigns(:task).should equal(mock_task)
      end

      it "should re-render the 'edit' template" do
        Task.stub!(:find).and_return(mock_task(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    before(:each) do
      get_data_for_sidebar
    end

    it "should destroy the requested task" do
      Task.should_receive(:find).with("37").and_return(mock_task)
      mock_task.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the tasks list" do
      Task.stub!(:find).and_return(mock_task(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(tasks_url)
    end

  end

end