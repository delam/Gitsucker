class WelcomeController < ApplicationController

  def index
    @results = nil
    @name = params[:name]

    if request.post? || params[:sort]
        
      forks = Octokit.forks(@name)
      users = []
      forks.each do |f|
          
        # look up the forked owner
        # init this crap
        js_projects = 0
        ruby_projects = 0
        original = 0
        forked = 0
        
        repositories = Octokit.repositories(f.owner.login)
        repositories.each do |repo|
          # what language
          repo.language && repo.language.downcase == 'ruby' ? ruby_projects = ruby_projects + 1 : repo.language && repo.language.downcase == 'javascript' ? js_projects = js_projects + 1 : nil
          
          # forked or not?
          repo.fork ? forked = forked + 1 : original = original + 1
        end

        # store the data about the user
        users << {:name => f.owner.login, :num_repos => repositories.size, :js_projects => js_projects, :ruby_projects => ruby_projects, :forked => forked, :original => original}

      end

      logger.debug(users.inspect)
      
      # sort the results
      s = params[:sort] ? params[:sort].to_sym : :original
      users.sort_by!{|u| u[s]}.reverse!
      @results = users
    
    end
  end
end
