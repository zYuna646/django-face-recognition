import tensorflow as tf
import os

# Tentukan direktori tempat file .h5 berada
model_dir = os.path.dirname(os.path.abspath(__file__))

# Loop semua file di direktori
for filename in os.listdir(model_dir):
    if filename.endswith(".h5"):
        h5_path = os.path.join(model_dir, filename)
        
        # Nama file baru dengan ekstensi .keras
        keras_filename = filename.replace(".h5", ".keras")
        keras_path = os.path.join(model_dir, keras_filename)
        
        try:
            # Load dan simpan ulang dalam format .keras
            model = tf.keras.models.load_model(h5_path, compile=False)
            model.save(keras_path, save_format='keras')
            print(f"Converted {filename} → {keras_filename}")
        except Exception as e:
            print(f"❌ Failed to convert {filename}: {e}")
