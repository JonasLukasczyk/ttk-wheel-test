rm -rf ./dist
sudo docker rm ttk-wheel-container
sudo docker create --name ttk-wheel-container ttk-wheel
sudo docker cp ttk-wheel-container:/src/ttk/wheelhouse ./dist

