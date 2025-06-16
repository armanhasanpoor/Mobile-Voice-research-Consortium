from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess
import os

app = Flask(__name__)
CORS(app)

PRAAT_SCRIPT_PATH = '/home/ahassanp/praat_server/praat_scripts/optimized_cpps.praat'



WAV_FOLDER = '/home/ahassanp/praat_server/static'

@app.route('/analyze', methods=['GET'])
def analyze():
    filename = request.args.get('file')
    if not filename or not filename.endswith('.wav'):
        return jsonify({'error': 'Missing or invalid .wav filename'}), 400

    wav_path = os.path.join(WAV_FOLDER, filename)
    if not os.path.exists(wav_path):
        return jsonify({'error': f'File not found: {filename}'}), 404
    
    try:
        result = subprocess.run([
         'praat', '--run', PRAAT_SCRIPT_PATH,
         'wav', WAV_FOLDER, '60', '5000', '50', '60', '330', '1', '0.02', '0.0005', 'Straight'
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

# Only treat it as failure if stderr contains real errors (not "Done!")
        if "Error:" in result.stderr and "Done!" not in result.stderr:
             return jsonify({'error': f'Praat script failed: {result.stderr}'}), 500


        print("PRAAT STDOUT:", result.stdout)
        print("PRAAT STDERR:", result.stderr)

        txt_path = wav_path.replace('.wav', '.txt')

        if not os.path.exists(txt_path):
            return jsonify({'error': f'Praat output not found at {txt_path}'}), 500

        with open(txt_path, 'r') as f:
            lines = f.readlines()
            header = lines[0].strip().split(',')
            values = lines[1].strip().split(',')
            return jsonify(dict(sorted(zip(header, values))))


    except subprocess.CalledProcessError as e:
        return jsonify({'error': f'Praat script failed: {e.stderr}'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)


# http://127.0.0.1:5000/analyze?file=track24.wav

