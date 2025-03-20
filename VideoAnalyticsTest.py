import random
import unittest
import cv2
from Utils.VideoAnalyticsModelService import VideoAnalyticsModelService

class TestVideoAnalyticsModelService(unittest.TestCase):
    def setUp(self):
        self.model_service = VideoAnalyticsModelService(model_path='yolo11n.pt')
        self.color_map = {}
        self.thickness = 1

    def draw_single_detection(self, frame, detection):
        boundary = detection['bbox'][0]
        classifier_id = detection['class'].item()
        classifier_name= detection['name']
        assurance_score = detection['confidence'].item()

        if classifier_id not in self.color_map:
            self.color_map[classifier_id] = self.generate_random_color()

        cv2.rectangle(frame, (int(boundary[0]), int(boundary[1])), (int(boundary[2]), int(boundary[3])),
                      self.color_map[classifier_id], self.thickness)
        label = f"Class: {classifier_name}, Conf: {assurance_score:.2f}"
        cv2.putText(frame, label, (int(boundary[0]), int(boundary[1]) - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5,
                    self.color_map[classifier_id], self.thickness)
        return frame

    def draw_detections(self, frame, detections):
        for detection in detections:
            frame = self.draw_single_detection(frame, detection)
        return frame

    def generate_random_color(self):
        return (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))

    def test_analyze_frame(self):
        # Load the video file
        cap = cv2.VideoCapture('test.webm')
        if not cap.isOpened():
            self.fail("Failed to open video file")

        # Get video properties
        frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = cap.get(cv2.CAP_PROP_FPS)

         # Define the codec and create VideoWriter object
        out = cv2.VideoWriter('output_with_detections.mp4', cv2.VideoWriter_fourcc(*'mp4v'), fps, (frame_width, frame_height))

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            # Encode frame as JPEG and convert to bytes
            _, buffer = cv2.imencode('.jpg', frame)
            frame_bytes = buffer.tobytes()

            # Analyze the frame
            result = self.model_service.analyze_frame(frame_bytes)

            # Check that the result contains detections
            self.assertIn('detections', result)
            self.assertIsInstance(result['detections'], list)

            # Draw detections on the frame
            self.draw_detections(frame, result['detections'])

            # Write the frame with detections to the output video
            out.write(frame)

        cap.release()
        out.release()

        # Play the output video using a video player
        cap = cv2.VideoCapture('output_with_detections.mp4')
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            cv2.imshow('Output Video with Detections', frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

        cap.release()
        cv2.destroyAllWindows()

if __name__ == '__main__':
    unittest.main()