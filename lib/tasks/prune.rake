namespace :prune do
  desc "Prune old, non-premium shortened urls"
  task short_urls: :environment do
    puts "Pruning urls..."
    ShortenedUrl.prune
  end
end
