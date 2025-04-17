import subprocess
import os

def convert_media_format(input_path: str, output_path: str):
    # Check if input has audio/video stream
    stream_check = subprocess.run(
        ["ffmpeg", "-i", input_path],
        stderr=subprocess.PIPE,
        stdout=subprocess.PIPE,
        text=True
    )
    
    stderr_output = stream_check.stderr.lower()

    if output_path.endswith(".mp3") or output_path.endswith(".wav"):
        if "audio:" not in stderr_output:
            raise ValueError("No audio stream found in the input file.")
    elif output_path.endswith(".mp4") or output_path.endswith(".mov"):
        if "video:" not in stderr_output:
            raise ValueError("No video stream found in the input file.")

    # Do the actual conversion
    subprocess.run([
        "ffmpeg",
        "-y",
        "-i", input_path,
        output_path
    ], check=True)
