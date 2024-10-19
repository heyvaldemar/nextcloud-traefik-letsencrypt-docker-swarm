# Nextcloud with Let's Encrypt in a Docker Swarm

Install Docker Swarm by following my [guide](https://www.heyvaldemar.com/install-docker-swarm-on-ubuntu-server/).

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik [configuration](https://github.com/heyValdemar/traefik-letsencrypt-docker-swarm).

Create a secret for storing the password for Nextcloud database using the command:

`printf "YourPassword" | docker secret create nextcloud-postgres-password -`

Create a secret for storing the password for Nextcloud admin using the command:

`printf "YourPassword" | docker secret create nextcloud-admin-password -`

Clear passwords from bash history using the command:

`history -c && history -w`

Run `nextcloud-restore-application-data.sh` on the Docker Swarm worker node where the container for backups is running to restore application data if needed.

Run `nextcloud-restore-database.sh` on the Docker Swarm node where the container for backups is running to restore database if needed.

Run `docker stack ps nextcloud | grep nextcloud_backups | awk 'NR > 0 {print $4}'` on the Docker Swarm manager node to find on which node container for backups is running.

Deploy Nextcloud in a Docker Swarm using the command:

`docker stack deploy -c nextcloud-traefik-letsencrypt-docker-swarm.yml nextcloud`

# Background Jobs Using Cron

To ensure your Nextcloud instance operates efficiently, it's important to use the "Cron" method to execute background jobs. A dedicated Docker container has already been set up in your environment to handle these tasks.

## Steps to Enable Cron:

1. **Log in to Nextcloud as an Administrator.**
2. Go to **Administration settings** (click on your user profile in the top right corner and select "Administration settings").
3. In the **Administration** section on the left sidebar, select **Basic settings**.
4. Scroll down to the **Background jobs** section.
5. Select the **"Cron (Recommended)"** option.

![nextcloud-cron](https://github.com/user-attachments/assets/0d593045-8fc2-411b-ad93-72b31659dc28)

## Why Use Cron?

The "Cron" method ensures that background tasks, such as file indexing, notifications, and cleanup operations, run at regular intervals independently of user activity. This method is more reliable and efficient than AJAX or Webcron, particularly for larger or more active instances, as it does not depend on users accessing the site to trigger these tasks. With the dedicated container in your setup, this method keeps your Nextcloud instance responsive and in good health by running these jobs consistently.

# Disabling Skeleton Directory for New Users

New Nextcloud users typically receive default files and folders upon account creation, which are sourced from the skeleton directory. Disabling this feature can be useful to provide a clean start for users and reduce disk usage. Use the `occ config:system:set` command to set the skeleton directory path to an empty string, effectively disabling the default content for new users.

List all running containers to find the one running Nextcloud:

`docker ps`

Run the command below, replacing `nextcloud-container-name` with your container's name. Adjust `33` to the correct user ID if different:

`docker exec -u 33 -it nextcloud-container-name php occ config:system:set skeletondirectory --value=''`

# Fixing Database Index Issues

Your Nextcloud database might be missing some indexes. This situation can occur because adding indexes to large tables can take considerable time, so they are not added automatically. Running `occ db:add-missing-indices` manually allows these indexes to be added while the instance continues running. Adding these indexes can significantly speed up queries on tables like `filecache` and `systemtag_object_mapping`, which might be missing indexes such as `fs_storage_path_prefix` and `systag_by_objectid`.

List all running containers to find the one running Nextcloud:

`docker ps`

Run the command below, replacing `nextcloud-container-name` with your container's name. Adjust `33` to the correct user ID if different:

`docker exec -u 33 -it nextcloud-container-name php occ db:add-missing-indices`

Confirm the indices were added by checking the status:

`docker exec -u 33 -it nextcloud-container-name php occ status`

- Operations on large databases can take time; consider scheduling during low-usage periods.
- Always backup your database before making changes.

# Rescanning Files

When files are added directly to Nextcloud's data directory through methods other than the web interface or sync clients (e.g., via FTP or direct server access), they are not automatically visible in the Nextcloud user interface. This happens because these files bypass Nextcloud's normal indexing process.

To make all manually added files visible in the UI, you can use the `occ files:scan` command to update Nextcloud's file index. This command should be used with care as it can impact server performance, especially on larger installations.

List all running containers to find the one running Nextcloud:

`docker ps`

Run the command below, replacing `nextcloud-container-name` with your container's name. Adjust `33` to the correct user ID if different:

`docker exec -u 33 -it nextcloud-container-name php occ files:scan --all`

- Be aware that this command can significantly affect performance during its execution. It is advisable to run this scan during periods of low user activity.
- Always ensure that you have up-to-date backups before performing any operations that affect the filesystem or database.

# Author

I’m Vladimir Mikhalev, the [Docker Captain](https://www.docker.com/captains/vladimir-mikhalev/), but my friends can call me Valdemar.

🌐 My [website](https://www.heyvaldemar.com/) with detailed IT guides\
🎬 Follow me on [YouTube](https://www.youtube.com/channel/UCf85kQ0u1sYTTTyKVpxrlyQ?sub_confirmation=1)\
🐦 Follow me on [Twitter](https://twitter.com/heyValdemar)\
🎨 Follow me on [Instagram](https://www.instagram.com/heyvaldemar/)\
🧵 Follow me on [Threads](https://www.threads.net/@heyvaldemar)\
🐘 Follow me on [Mastodon](https://mastodon.social/@heyvaldemar)\
🧊 Follow me on [Bluesky](https://bsky.app/profile/heyvaldemar.bsky.social)\
🎸 Follow me on [Facebook](https://www.facebook.com/heyValdemarFB/)\
🎥 Follow me on [TikTok](https://www.tiktok.com/@heyvaldemar)\
💻 Follow me on [LinkedIn](https://www.linkedin.com/in/heyvaldemar/)\
🐈 Follow me on [GitHub](https://github.com/heyvaldemar)

# Communication

👾 Chat with IT pros on [Discord](https://discord.gg/AJQGCCBcqf)\
📧 Reach me at ask@sre.gg

# Give Thanks

💎 Support on [GitHub](https://github.com/sponsors/heyValdemar)\
🏆 Support on [Patreon](https://www.patreon.com/heyValdemar)\
🥤 Support on [BuyMeaCoffee](https://www.buymeacoffee.com/heyValdemar)\
🍪 Support on [Ko-fi](https://ko-fi.com/heyValdemar)\
💖 Support on [PayPal](https://www.paypal.com/paypalme/heyValdemarCOM)
