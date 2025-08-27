This is a web application written using Ruby on Rails 8 framework.

## Project guidelines

- Run `bundle exec rubocop` before committing to ensure code quality and fix any style violations
- Run `bin/rails test` to execute the test suite and ensure all tests pass
- Use the built-in `:net/http` or `Faraday` gem for HTTP requests, **avoid** `:httpclient` or `:rest-client`
- Follow the principle of "Convention over Configuration" - Rails defaults are there for a reason
- Leverage Rails’ defaults and structure. For example, place models in app/models, controllers in app/controllers, etc., and name classes and files according to Rails conventions (e.g. User model in user.rb). Rails auto-loads files based on naming, so **never** violate naming conventions or file structure, e.g. keep one class or module per file, with the file name matching the class name . This ensures Rails (with Zeitwerk autoloader) loads your code correctly.
- Use Bundler to manage gems. **Always** run bundle install after modifying the Gemfile. Avoid running bundle update without specifying a gem; update all gems only when you intend to (to prevent unintended version bumps). **Never** include multiple gems that solve the same problem – prefer the chosen libraries in the project.
- Use Ruby/Rails built-ins before adding new dependencies.
- Keep secrets out of code. Use Rails encrypted credentials (config/credentials.yml.enc) or environment variables for API keys, passwords, etc. **Never** hard-code secrets in code or commit them to the repository. Use initializers for configuration that needs to run on boot, and keep environment-specific settings in config/environments/* files.

### Rails 8 Guidelines

- **MVC Responsibility:** Keep a **clear separation of concerns**
**Controllers**: Should be skinny, handling request/response and coordination. **Never** put heavy business logic in controllers. If you find a controller method doing a lot, consider moving logic into the model or a service object. Controllers should mostly fetch data from models and decide which view or redirect to use.
- **Models**: Hold the business logic and database interactions (ActiveRecord models). It’s normal for models to be “fat” with validations, associations, and methods encapsulating business rules. Keep code that deals with data or rules in the model. For example, a method to calculate a price or check a condition on a record belongs in the model rather than recalculating in the controller.
- **Views**: Should be as logic-free as possible, focusing on presentation. **Never** perform complex calculations or database queries directly in views. Use helper methods or view components to encapsulate logic needed for display (like formatting dates or numbers). This keeps templates clean.
- Rails is an opinionated framework – **embrace its conventions**. For example, use **RESTful routes** and resourceful controllers. Follow naming conventions in routes and controllers so that helpers work automatically. **Avoid** non-REST endpoints if a standard RESTful approach would work. Limit controller actions to the standard seven (index, show, new, create, edit, update, destroy)
- When you need additional actions, consider creating a new controller for a new resource concept
- Organize routes for clarity and maintainability
- Use resources :items for CRUD routes and leverage options like only/except to limit routes if not all are needed.
- **Never** create deeply nested routes more than 1 level deep. The Rails guide recommends nesting resources only one level to avoid complex URLs and helper names . If you have resources :magazines and resources :ads nested, that’s fine, but a third level (like publishers/:id/magazines/:id/ads/:id) becomes cumbersome . Use **shallow nesting** if you need to reference a parent in URLs for context but want to avoid long URL chains
- Use namespace for grouping routes under an admin or API namespace, which automatically looks for controllers in subdirectories. **Never** hard-code the controller path in the route if using namespace or scope module: Rails will do it. For example, namespace :admin do resources :users end will route to Admin::UsersController without any extra configuration
- Use route **helpers** (like users_path, new_user_path) instead of hardcoding URLs. This ensures changes in routes propagate to all links.
- **Strong Parameters:** Always use Strong Parameters in controllers for mass assignment protection  . **Never** pass params directly to model methods like Model.create or update without filtering. Instead, use params.require(...).permit(...) to whitelist acceptable fields. This prevents users from updating sensitive attributes that you didn’t intend to expose. For example, in a UsersController, do:
```ruby
def create
  @user = User.new(user_params)  # user_params uses require/permit
  ...
end

private
  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
```
This ensures things like admin flag or role cannot be set via malicious form input. **Never** permit foreign keys or sensitive flags if they should be controlled by the app (e.g. user_id on a comment should come from current_user, not from the form).
- Rails 8 uses Solid Queue, Solid Cache, and Solid Cable by default - these replace Redis for most use cases
- Use `rails generate` commands to create files following Rails conventions
- **Always** run migrations with `bin/rails db:migrate` after generating models
- Rails 8 includes Hotwire (Turbo + Stimulus) by default for frontend interactivity
- Use `bin/rails` for all Rails commands, not `rake` (deprecated for most tasks)
- Authentication can be generated with `bin/rails generate authentication` in Rails 8

<!-- usage-rules-start -->
<!-- rails:ruby-start -->
## Ruby Guidelines

### Ruby 3.4 Specific Features
- Use `it` for simple block parameters where appropriate: `items.map { it.upcase }`
- `it` behaves like `_1` but is more readable for simple one-line blocks
- Ruby 3.4 uses Prism as the default parser (internal improvement)
- Happy Eyeballs Version 2 is enabled by default for socket connections
- Frozen string literals improve performance - use `# frozen_string_literal: true` at the top of files

### Core Ruby Patterns
- Ruby uses **symbols** (`:symbol`) for identifiers that won't change
- **Never** modify collections while iterating over them:
  ```ruby
  # BAD
  array.each { |item| array.delete(item) if condition }

  # GOOD
  array.reject! { |item| condition }
  ```

- Use **predicate methods** ending with `?` for boolean returns:
  ```ruby
  def valid?
    # returns true or false
  end
  ```

- Use **bang methods** ending with `!` for dangerous/mutating operations:
  ```ruby
  array.sort   # returns sorted copy
  array.sort!  # sorts in place
  ```

### Variable and Method Access
- Ruby **does not support** array/hash access on custom objects without defining `[]` method
- Instance variables start with `@`, class variables with `@@`
- **Never** use `String.to_sym` on user input (memory leak risk)
- Constants are UPPERCASE_WITH_UNDERSCORES and should not be reassigned

### Blocks, Procs, and Lambdas
- Blocks are not objects, use `Proc` or `lambda` when you need to store/pass them
- Prefer `lambda` over `Proc` for stricter argument checking:
  ```ruby
  # Lambda checks argument count
  my_lambda = ->(x) { x * 2 }

  # Proc is more lenient
  my_proc = Proc.new { |x| x * 2 }
  ```

### Exception Handling
- Use `begin/rescue/ensure/end` for exception handling
- **Always** rescue specific exceptions, never rescue bare `Exception`:
  ```ruby
  # BAD
  rescue Exception => e

  # GOOD
  rescue StandardError => e
  rescue ActiveRecord::RecordNotFound => e
  ```
<!-- rails:ruby-end -->

<!--rails:rails-start -->
## Rails Guidelines

### Naming Conventions
- **Models**: Singular, PascalCase (e.g., `User`, `BlogPost`)
- **Controllers**: Plural, PascalCase with "Controller" suffix (e.g., `UsersController`, `BlogPostsController`)
- **Database tables**: Plural, snake_case (e.g., `users`, `blog_posts`)
- **Routes**: Use resources for RESTful routes, plural names
- **Views**: Directory matches controller name (plural), files match actions
- **Helpers**: Match controller names (e.g., `UsersHelper`)

### MVC Architecture
- **Fat Models, Skinny Controllers**: Business logic belongs in models
- Controllers should only:
  - Handle request parameters
  - Call model methods
  - Prepare data for views
  - Handle responses (render/redirect)
- **Never** put business logic in views or helpers
- Helpers are for view formatting only

### Controller Guidelines

#### RESTful Actions
- Stick to the seven RESTful actions when possible:
  ```ruby
  class PostsController < ApplicationController
    def index; end    # GET /posts
    def show; end     # GET /posts/:id
    def new; end      # GET /posts/new
    def create; end   # POST /posts
    def edit; end     # GET /posts/:id/edit
    def update; end   # PATCH/PUT /posts/:id
    def destroy; end  # DELETE /posts/:id
  end
  ```

#### Strong Parameters
- **Always** use strong parameters for mass assignment protection:
  ```ruby
  private

  def post_params
    params.require(:post).permit(:title, :body, :published)
  end
  ```

- **Never** use `params.permit!` in production code

#### Before Actions
- Use `before_action` for common setup:
  ```ruby
  class PostsController < ApplicationController
    before_action :set_post, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: [:index, :show]

    private

    def set_post
      @post = Post.find(params[:id])
    end
  end
  ```

#### Response Formats
- Use `respond_to` for multiple formats:
  ```ruby
  def show
    respond_to do |format|
      format.html
      format.json { render json: @post }
      format.turbo_stream
    end
  end
  ```

### Routing Guidelines

- Use `resources` for RESTful routes:
  ```ruby
  Rails.application.routes.draw do
    resources :posts do
      resources :comments, only: [:create, :destroy]
    end

    namespace :admin do
      resources :users
    end

    root "posts#index"
  end
  ```

- Use constraints for advanced routing:
  ```ruby
  constraints subdomain: 'api' do
    namespace :api do
      resources :posts
    end
  end
  ```

- Keep routes file organized and commented
- Use `member` and `collection` for additional RESTful actions

### Testing with Minitest

#### Test Structure
- Tests inherit from `ActiveSupport::TestCase` (models) or `ActionDispatch::IntegrationTest` (controllers)
- Test files mirror app structure: `test/models/user_test.rb`
- Use `test` method or `def test_` prefix:
  ```ruby
  class UserTest < ActiveSupport::TestCase
    test "should not save user without email" do
      user = User.new
      assert_not user.save
    end
  end
  ```

#### Setup and Teardown
- Use `setup` and `teardown` for test preparation:
  ```ruby
  class PostTest < ActiveSupport::TestCase
    def setup
      @post = posts(:one)  # uses fixtures
    end

    def teardown
      # cleanup if needed
    end
  end
  ```

#### Assertions
- Common assertions:
  ```ruby
  assert user.valid?
  assert_equal "expected", actual
  assert_nil value
  assert_raises(ErrorClass) { code }
  assert_difference 'Post.count', 1 do
    Post.create(title: "Test")
  end
  ```

#### Fixtures
- Fixtures provide test data in `test/fixtures/`:
  ```yaml
  # test/fixtures/users.yml
  one:
    email: user1@example.com
    name: User One

  two:
    email: user2@example.com
    name: User Two
  ```

- Access fixtures with: `users(:one)`
- Fixtures are loaded in a transaction and rolled back

#### Integration Tests
- Test full request/response cycle:
  ```ruby
  class PostsFlowTest < ActionDispatch::IntegrationTest
    test "can create a post" do
      get new_post_path
      assert_response :success

      post posts_path, params: { post: { title: "Test" } }
      assert_response :redirect
      follow_redirect!
      assert_response :success
      assert_select "h1", "Test"
    end
  end
  ```

#### System Tests
- Test with real browser (uses Selenium):
  ```ruby
  class PostsTest < ApplicationSystemTestCase
    test "creating a Post" do
      visit posts_url
      click_on "New Post"

      fill_in "Title", with: "Test Post"
      click_on "Create Post"

      assert_text "Post was successfully created"
    end
  end
  ```

#### Test Coverage
- Run specific tests: `bin/rails test test/models/user_test.rb`
- Run single test: `bin/rails test test/models/user_test.rb:15`
- Use `--fail-fast` to stop on first failure
- Parallel testing enabled by default in Rails 8
<!-- rails:rails-end -->
<!-- rails:activerecord-start -->
### ActiveRecord Guidelines

#### Schema Conventions
- Primary keys: Always `id` (bigint)
- Foreign keys: `<model>_id` (e.g., `user_id`, `post_id`)
- Timestamps: `created_at` and `updated_at` (automatically managed)
- Boolean fields: Use `?` suffix in methods (e.g., `published?` for `published` column)
- Counter cache: `<association>_count` (e.g., `comments_count`)

#### Associations
- **Always** use Rails association methods:
  ```ruby
  class Post < ApplicationRecord
    belongs_to :user
    has_many :comments, dependent: :destroy
    has_many :commenters, through: :comments, source: :user
  end
  ```

- **Never** manually write foreign key queries
- Use `dependent:` option to handle cleanup:
  - `:destroy` - runs callbacks on associated objects
  - `:delete_all` - deletes without callbacks (faster)
  - `:nullify` - sets foreign key to NULL
  - `:restrict_with_error` - prevents deletion if associations exist

#### Validations
- Validations belong in models, not controllers:
  ```ruby
  class User < ApplicationRecord
    validates :email, presence: true, uniqueness: true
    validates :age, numericality: { greater_than: 0 }
  end
  ```

- Use database constraints as backup (null: false, unique indexes)
- Custom validations should be private methods

#### Scopes and Queries
- Use scopes for reusable queries:
  ```ruby
  class Post < ApplicationRecord
    scope :published, -> { where(published: true) }
    scope :recent, -> { order(created_at: :desc) }
  end
  ```

- **Always** use `includes` to avoid N+1 queries:
  ```ruby
  # BAD - N+1 query
  posts = Post.all
  posts.each { |post| puts post.user.name }

  # GOOD - eager loading
  posts = Post.includes(:user)
  posts.each { |post| puts post.user.name }
  ```

- Use `find_by` instead of `where().first`
- Use `exists?` instead of `count > 0`

#### Callbacks
- Use callbacks sparingly - they can make debugging difficult
- Order matters: callbacks run in the order they're defined
- Common callbacks: `before_save`, `after_create`, `after_commit`
- **Avoid** callbacks that touch other models
<!-- rails:activerecord-end -->
<!-- rails:html-start -->
### View Guidelines

#### ERB Templates
- Use `<%= %>` for output, `<% %>` for logic
- **Never** put complex logic in views
- Extract repeated code into partials
- Partials start with underscore: `_post.html.erb`
- Use locals when rendering partials:
  ```erb
  <%= render partial: 'post', locals: { post: @post } %>
  <!-- or shorthand for single object -->
  <%= render @post %>
  ```

#### Helpers
- Helpers are for view formatting only:
  ```ruby
  module ApplicationHelper
    def formatted_date(date)
      date.strftime("%B %d, %Y")
    end
  end
  ```

- **Never** access database from helpers
- Built-in helpers to know: `link_to`, `form_with`, `image_tag`, `content_tag`

#### Forms
- **Always** use `form_with` for forms:
  ```erb
  <%= form_with model: @post do |form| %>
    <%= form.text_field :title %>
    <%= form.text_area :body %>
    <%= form.submit %>
  <% end %>
  ```

- Forms automatically include CSRF tokens
- Use form builders for consistent styling
<!-- rails:html-end -->
<!-- rails:hotwire-start -->
### Hotwire Guidelines (Turbo + Stimulus)
Rails 8 continues to embrace **Hotwire** (Turbo and Stimulus) for rich interactive UIs without hand-writing a lot of JS.  Here are guidelines for using these tools best practices:

#### Turbo Frames
- Wrap independent sections in turbo frames:
  ```erb
  <%= turbo_frame_tag "post_#{post.id}" do %>
    <%= render post %>
  <% end %>
  ```

- **Always** use unique IDs for frames
- Frames only update matching frame IDs
- Use `target="_top"` to break out of frame

#### Turbo Streams
- Use for real-time updates:
  ```ruby
  # Controller
  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: turbo_stream.append("posts", partial: "post", locals: { post: @post })
    end
  end
  ```

- Stream actions: append, prepend, replace, update, remove
- Can broadcast from models:
  ```ruby
  class Post < ApplicationRecord
    after_create_commit { broadcast_append_to "posts" }
  end
  ```

#### Stimulus Controllers
- JavaScript controllers for interactivity:
  ```javascript
  // app/javascript/controllers/hello_controller.js
  import { Controller } from "@hotwired/stimulus"

  export default class extends Controller {
    static targets = ["output"]

    connect() {
      console.log("Connected")
    }

    greet() {
      this.outputTarget.textContent = "Hello!"
    }
  }
  ```

- HTML usage:
  ```erb
  <div data-controller="hello">
    <button data-action="click->hello#greet">Greet</button>
    <span data-hello-target="output"></span>
  </div>
  ```

- **Turbo Drive and Links/Forms:** By default, Rails (with Turbo) makes <a> links and form submissions perform AJAX navigation/updates. Embrace this:
  - **Never** disable Turbo (e.g., by adding data-turbo="false") on links or forms unless you have a specific need (like a link that must do a full page reload or a form that uploads files without direct support). Using Turbo’s default behavior results in faster page transitions and keeps state (like scroll position) by default.
  - Use turbo_frame_tag for framing independent sections of the page that can load or update separately. For example, a list that updates via Turbo Stream can be wrapped in <turbo-frame id="messages">...</turbo-frame> so it can update without a full page refresh.
  - **Turbo Streams (Server-Sent Updates):** Rails can stream partial page updates via ActionCable or on form submissions:
  - **Always** respond to create/update/destroy actions with Turbo Stream format if these actions should update a list or element on the page. For instance, in your controller:
    ```ruby
    respond_to do |format|
      format.html { redirect_to @post }
      format.turbo_stream  # will render create.turbo_stream.erb by convention
    end
    ```
    And in create.turbo_stream.erb, you might have:
    <%= turbo_stream.append "posts", partial: "posts/post", locals: { post: @post } %>
    This appends a new post to the list in the posts DOM element.

  - Use Turbo stream helpers like turbo_stream.append, turbo_stream.prepend, turbo_stream.replace etc., in your .turbo_stream.erb view templates to declaratively update the DOM. Ensure the target elements have an id matching what you use in the stream action.
	- **Never** manually write JavaScript to handle server responses for adding/removing elements if Turbo Streams can handle it. Avoid writing custom JS to do DOM updates on form success; instead rely on Turbo’s stream response which is simpler and less error-prone.
	- For real-time updates (like broadcasting new messages to all users), use **ActionCable with Turbo Streams**. For example, Rails 7+ allows models to broadcast changes: after_create_commit { broadcast_append_to "messages" }. This sends a Turbo Stream update to any subscriber of “messages”. **Always** use these high-level helpers instead of writing raw WebSocket subscription code. It follows the Rails way of integrating real-time features.
	- **Empty states and conditional content:** Similar to Phoenix LiveView, handle empty lists by including an element that is shown when a list is empty. For example, you might have:
  ```
  <div id="tasks">
    <% if @tasks.any? %>
      <% @tasks.each do |task| %>
        <%= render task %>
      <% end %>
    <% else %>
      <p id="no-tasks">No tasks yet</p>
    <% end %>
  </div>
  ```

If you are using Turbo Streams to append tasks, you might hide the “No tasks” message when tasks exist by targeting it in a replace/remove stream. Alternatively, use CSS like .hidden { display: none; } and toggle a class. **Always** ensure that dynamically updated sections have a plan for when they become empty or non-empty (so you don’t forever show “No tasks” even after adding one, for instance).

- **Stimulus (JavaScript Controllers):** Use Stimulus for adding client-side behaviors:
  - **Always** create a Stimulus controller when you need to handle DOM events or enhance UI elements with JavaScript. For example, form validation feedback, modal dialogs, toggling classes, etc., can be done with Stimulus controllers that are easy to attach via data-controller attributes.
  - Keep Stimulus controllers small and focused. For instance, a controller to toggle a dropdown might only have actions for showing/hiding the menu. Leverage Stimulus’ lifecycle callbacks (connect, disconnect) to initialize or clean up as needed.
  - **Never** put large blocks of inline JS in your ERB or use jQuery document.ready in an ad-hoc script tag. Instead, use Stimulus to organize that code. For example, if you need to auto-focus an input when a modal appears, create a Stimulus controller for the modal that handles the shown event and focuses the input. This keeps JS out of templates.
  - **Data Attributes:** Use data-* attributes for passing static configuration or selectors to Stimulus controllers rather than hardcoding selectors in JS. Stimulus makes this easy with data-controller, data-action, and data-<name>-target for identifying targets. Always prefer this declarative approach. For instance:
    ```
    <div data-controller="dropdown" data-action="click@window->dropdown#closeOutside">
      <button data-action="dropdown#toggle">Menu</button>
      <div data-dropdown-target="menu"> ... </div>
    </div>
    ```
    This sets up a dropdown controller with an action to close when clicking outside and toggling the menu on button click. This approach is clean and keeps behavior tied to markup.

  - **Cleaning up:** If your Stimulus controller sets up global listeners or timers, clean them up in disconnect(). **Never** assume a page reload will clear everything – with Turbo, pages might be cached or partially updated, so proper cleanup prevents memory leaks or multiple bindings.

⠀
-* **Turbo vs Traditional AJAX:** Avoid using older Rails UJS (Unobtrusive JS) approaches (data-remote="true" with custom .js.erb templates) now that Turbo is the default. Turbo covers most use cases of PJAX and AJAX form submission automatically. So:
  - **Never** use .js.erb response templates for updating the DOM if a Turbo Stream can achieve the same result. Turbo Streams are more straightforward and Rails-supported.
  -  If you have a truly custom AJAX case (like calling a JSON endpoint and doing something with the data via JS), you can still do that, but structure it via a Stimulus controller making an fetch() call, for example. Keep such cases to a minimum.
- **Progressive Enhancement:** Hotwire is built for progressive enhancement. Ensure your app still functions if Turbo is disabled (users might disable JS). For example, Turbo forms should fall back to a full page submit if JS is off. **Always** provide server-side responses for normal HTML as well as Turbo Stream. (Rails’ dual-format respond_to as shown above handles this).
- **Testing Turbo/Stimulus:** When writing system tests (using Capybara) for Turbo-driven interfaces, identify elements by stable selectors (like IDs or data-test attributes). **Always** give important elements unique IDs or data attributes for testing purposes. For example, the submit button for a form could have id="new-comment-submit" or similar. This makes tests using Capybara’s assert_selector or click_button reliable  . Avoid overly fragile selectors (like nth-child or text content that might change).
-* **No Inline Script Tags:** Just as Phoenix LiveView forbids inline scripts, in Rails you should **never** put inline <script> tags in HTML that manipulate DOM on load. Use external JS packs or Stimulus for behavior, keeping HTML clean. If you need to include a small script (for example, to initialize a third-party widget), consider wrapping it as a Stimulus controller or including it via the asset pipeline. This way, caching and compression apply, and it’s easier to maintain.

#### Best Practices
- Start with Turbo Frames for partial updates
- Add Turbo Streams for real-time features
- Use Stimulus for client-side interactivity
- **Avoid** mixing too many Turbo Streams - can become hard to debug
- Keep Stimulus controllers small and focused
<!-- rails:hotwire-end -->
<!-- usage-rules-end -->

### Security Guidelines

- **Always** use strong parameters
- **Never** trust user input
- Use `html_safe` sparingly - prefer `sanitize` or `raw`
- CSRF protection enabled by default
- Use `authenticate_user!` or similar for protected routes
- Store secrets in credentials: `rails credentials:edit`
- **Never** commit secrets to version control

### Performance Guidelines

- Use database indexes on foreign keys and commonly queried columns
- Implement caching:
  - Fragment caching for views
  - Russian doll caching for nested structures
  - Low-level caching with `Rails.cache`
- Use `counter_cache` for association counts
- Background jobs for time-consuming tasks (use Solid Queue in Rails 8)
- Optimize images with Active Storage variants
- Use `rails dev:cache` to test caching in development

### Debugging Tips

- Use `byebug` or `debug` gem for breakpoints
- `rails console` for interactive debugging
- `rails dbconsole` for direct database access
- Check logs in `log/development.log`
- Use `pp` (pretty print) for readable output
- `reload!` in console to reload code changes

### Common Pitfalls to Avoid

1. **N+1 Queries**: Always use `includes` for associations
2. **Fat Controllers**: Move logic to models or service objects
3. **Callback Hell**: Limit callbacks, consider service objects
4. **Untested Code**: Write tests as you code
5. **Ignoring Conventions**: Rails is opinionated for good reasons
6. **Raw SQL**: Use ActiveRecord methods when possible
7. **Skipping Validations**: Validate at model level, not just frontend
8. **Large Migrations**: Break into smaller, reversible chunks
9. **Storing Secrets in Code**: Use credentials or environment variables
10. **Premature Optimization**: Measure first, optimize second

## Development Workflow

1. Generate resources with Rails generators
2. Write tests first (TDD) or alongside code
3. Implement features following Rails conventions
4. Run tests: `bin/rails test`
5. Check code style: `bundle exec rubocop`
6. Review in `rails console` if needed
7. Commit with clear messages
8. Deploy using Kamal 2 (included in Rails 8)

## Deployment Considerations

- Rails 8 includes Kamal 2 for deployment
- Use `bin/rails assets:precompile` for production assets
- Set `RAILS_ENV=production` and `RAILS_MASTER_KEY`
- Configure Solid Queue, Solid Cache as needed
- Consider using Postgres or MySQL in production (not SQLite)
- Enable SSL/HTTPS in production
- Monitor with Rails built-in health checks at `/up`

Remember: **Convention over Configuration** - When in doubt, follow Rails conventions!

## MCP Servers
### Tidewave MCP Rules
  - Tidewave speeds up development because the AI can understand the web application, how it runs, and what it delivers.
  - The current Tidewave release includes open source tools that connect the AI to the web framework runtime via MCP.
### Figma Dev Mode MCP Rules
  - The Figma Dev Mode MCP Server provides an assets endpoint which can serve image and SVG assets
  - IMPORTANT: If the Figma Dev Mode MCP Server returns a localhost source for an image or an SVG, use that image or SVG source directly
  - IMPORTANT: DO NOT import/add new icon packages, all the assets should be in the Figma payload
  - IMPORTANT: do NOT use or create placeholders if a localhost source is provided
  - IMPORTANT: this project uses TailwindCSS and daisyUI

