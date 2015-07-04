--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Control.Applicative ((<$>))
import           Data.Monoid         ((<>), mconcat)
import           Prelude             hiding (id)
import qualified Text.Pandoc         as Pandoc
import Data.List (isPrefixOf, tails, findIndex, intercalate, sortBy)

import           Hakyll
import           Hakyll.Web.Tags


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
  -- | Images files
  match ("images/*.jpg" .||. "images/*.png" .||. "images/*/*.jpg" .||.  "images/flat_web_icon_set/*.png" .||. "favicon.ico") $ do
    route   idRoute
    compile copyFileCompiler

  -- | Static files
  match ("static/js/*.js" .||. "static/fonts/*" ) $ do
    route   idRoute
    compile copyFileCompiler
  
  -- | Compress CSS
  match "static/css/*" $ do
    route   idRoute
    compile compressCssCompiler

  -- | Build tags
  tags <- buildTags "posts/*" (fromCapture "tags/*.html")

  -- | Post tags
  tagsRules tags $ \tag pattern -> do
    let title = "Articles in category &quot;" ++ tag ++ "&quot;"
    -- 
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll pattern
      let ctx = constField "title" title <>               
                listField "posts" (postCtx tags) (return posts) <>
                defaultContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx
        >>= relativizeUrls

  -- | Some basic static pages
  match (fromList ["about.md", "contact.markdown"]) $ do
    route   $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/page.html" defaultContext
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls

  -- | Blog posts
  match "posts/*" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
      >>= saveSnapshot "post-excerpt"
      >>= loadAndApplyTemplate "templates/post.html"    (postCtx tags)
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls

  -- | List of posts
  create ["archive.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx =
            constField "title" "Archive" <>
            listField "posts" (postCtx tags) (return posts) <>
            defaultContext

      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls

  -- | Main page
  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- fmap (take 5) . recentFirst =<< loadAllSnapshots "posts/*" "post-excerpt"
      let indexCtx =
            listField "posts" (excerptCtx tags) (return posts) <>            
            defaultContext
      
      getResourceBody
        >>= applyAsTemplate indexCtx
        >>= loadAndApplyTemplate "templates/post-list.html" indexCtx
        >>= loadAndApplyTemplate "templates/default.html" indexCtx
        >>= relativizeUrls

  -- | Templates
  match "templates/*" $ compile templateCompiler

--------------------------------------------------------------------------------
postCtx :: Tags -> Context String
postCtx tags = mconcat
               [ dateField "date" "%B %e, %Y"
               , tagsField "tags" tags
               , defaultContext
               ]

excerptCtx :: Tags -> Context String
excerptCtx tags = teaserField "excerpt" "post-excerpt" <> (postCtx tags)
