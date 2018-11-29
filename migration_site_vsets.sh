#!/bin/bash

## Drush vset of all settings
echo "Drush vset of Drupal Site configurations"
drush -u 1 -y vset islandora_base_url "fedora:8080/fedora"
drush -u 1 -y vset islandora_solr_url "solr:8080/solr"
drush -u 1 -y vset imagemagick_convert "/usr/local/bin/convert"
drush -u 1 -y vset image_toolkit "imagemagick"
drush -u 1 -y vset islandora_ocr_tesseract "/usr/bin/tesseract"
drush -u 1 -y vset islandora_checksum_checksum_type "SHA-1"
drush -u 1 -y vset islandora_checksum_enable_checksum "TRUE"
drush -u 1 -y vset islandora_pdf_create_fulltext "1"
drush -u 1 -y vset islandora_batch_java "/usr/bin/java"
drush -u 1 -y vset islandora_lame_url "/usr/bin/lame"
drush -u 1 -y vset islandora_paged_content_gs "/usr/bin/gs"
drush -u 1 -y vset islandora_video_ffmpeg_path "/usr/bin/ffmpeg"
drush -u 1 -y vset islandora_video_ffmpeg2theora_path "/usr/bin/ffmpeg2theora"
drush -u 1 -y vset islandora_use_kakadu "TRUE"
drush -u 1 -y vset islandora_kakadu_url "/usr/local/bin/kdu_compress"
drush -u 1 -y vset islandora_pdf_path_to_pdftotext "/usr/bin/pdftotext"
drush -u 1 -y vset islandora_fits_executable_path "/usr/local/bin/fits"
drush -u 1 -y vset islandora_paged_content_djatoka_url '/adore-djatoka'
drush -u 1 -y vset --format=json islandora_openseadragon_settings '{"debugMode":0,"djatokaServerBaseURL":"\/adore-djatoka\/resolver","animationTime":"1.5","blendTime":"0.1","alwaysBlend":0,"autoHideControls":1,"immediateRender":0,"wrapHorizontal":0,"wrapVertical":0,"wrapOverlays":0,"panHorizontal":1,"panVertical":1,"showNavigator":1,"minZoomImageRatio":"0.8","maxZoomPixelRatio":"2","visibilityRatio":"0.5","springStiffness":"5.0","imageLoaderLimit":"5","clickTimeThreshold":"300","clickDistThreshold":"5","zoomPerClick":"2.0","zoomPerScroll":"1.2","zoomPerSecond":"2.0"}'
# drush -u 1 -y vset --format=json islandora_audio_viewers '{"name":{"none":"none","islandora_videojs":"islandora_videojs"},"default":"islandora_videojs"}'
# drush -u 1 -y vset --format=json islandora_video_viewers '{"name":{"none":"none","islandora_videojs":"islandora_videojs"},"default":"islandora_videojs"}'
# drush -u 1 -y vset --format=json islandora_book_viewers '{"name":{"none":"none","islandora_internet_archive_bookreader":"islandora_internet_archive_bookreader"},"default":"islandora_internet_archive_bookreader"}'
# drush -u 1 -y vset --format=json islandora_book_page_viewers '{"name":{"none":"none","islandora_openseadragon":"islandora_openseadragon"},"default":"islandora_openseadragon"}'
# drush -u 1 -y vset --format=json islandora_large_image_viewers '{"name":{"none":"none","islandora_openseadragon":"islandora_openseadragon"},"default":"islandora_openseadragon"}'
# drush -u 1 -y vset --format=json islandora_newspaper_issue_viewers '{"name":{"none":"none","islandora_internet_archive_bookreader":"islandora_internet_archive_bookreader"},"default":"islandora_internet_archive_bookreader"}'
# drush -u 1 -y vset --format=json islandora_newspaper_page_viewers '{"name":{"none":"none","islandora_openseadragon":"islandora_openseadragon"},"default":"islandora_openseadragon"}'
# drush -u 1 -y vset --format=json islandora_pdf_viewers '{"name": {"none": "none","islandora_pdfjs": "islandora_pdfjs"},"default": "islandora_pdfjs"}'
drush -u 1 -y vset islandora_openseadragon_iiif_identifier '[islandora_openseadragon:pid]~[islandora_openseadragon:dsid]~[islandora_openseadragon:token]'
drush -u 1 -y vset islandora_openseadragon_iiif_token_header '0'
drush -u 1 -y vset islandora_openseadragon_iiif_url 'iiif/2'
# drush -u 1 -y vset islandora_openseadragon_tilesource 'iiif'
drush -u 1 -y vset islandora_internet_archive_bookreader_iiif_identifier '[islandora_iareader:pid]~[islandora_iareader:dsid]~[islandora_iareader:token]'
drush -u 1 -y vset islandora_internet_archive_bookreader_iiif_token_header '0'
drush -u 1 -y vset islandora_internet_archive_bookreader_iiif_url 'iiif/2'
# drush -u 1 -y vset islandora_internet_archive_bookreader_pagesource 'iiif'

echo "Re-running the islandora_paged_content_gs vset!"
drush -u 1 -y vset islandora_paged_content_gs "/usr/bin/gs"

echo "Re-running the islandora_video_mp4_audio_codec vset!"
drush -u 1 -y vset islandora_video_mp4_audio_codec "aac"

## Enable repo access to anonymous users.
drush rap 'anonymous user' 'view fedora repository objects'

# Fix site directory permissions
echo "Running fix-permissions script"
/bin/bash /utility-scripts/isle_drupal_build_tools/drupal/fix-permissions.sh --drupal_path=/var/www/html --drupal_user=islandora --httpd_group=www-data

## Cron job setup every three hours
echo "Configuring cron job to run every 3 hours"
echo "0 */3 * * * su -s /bin/bash www-data -c 'drush cron --root=/var/www/html --uri=${BASE_DOMAIN} --quiet'" >> crondrupal
crontab crondrupal
rm crondrupal

## Run cron first time, update update-status (rf), clear caches.
echo 'Running Drupal Cron first time and clearing Drupal Caches.'
su -s /bin/bash www-data -c 'drush cron && drush rf && drush cc all'

echo "Drush script finished! ...exiting"
exit
