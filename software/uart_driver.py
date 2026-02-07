import serial
import tkinter as tk
import pygame

# Parameters
SERIAL_PORT = 'COM3'
BAUD_RATE = 115200

# Joystick threshold (0.0 to 1.0)
STICK_DEADZONE = 0.5

ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.01)

# Initialise pygame joystick handling
pygame.init()
pygame.joystick.init()

# Check for controllers
joysticks = [pygame.joystick.Joystick(x) for x in range(pygame.joystick.get_count())]
if joysticks:
    print("Connected to controller")
    joysticks[0].init()
else:
    print("No controller found")

# Input mapping
controls = {
    'w':    {'press': b'W', 'release': b'w', 'label': 'P1 UP (W / L-Stick)'},
    's':    {'press': b'S', 'release': b's', 'label': 'P1 DOWN (S / L-Stick)'},
    'Up':   {'press': b'I', 'release': b'i', 'label': 'P2 UP (Arrow / R-Stick)'},
    'Down': {'press': b'K', 'release': b'k', 'label': 'P2 DOWN (Arrow / R-Stick)'}
}

active_keys = set()

def send_uart(byte_data):
    if ser and ser.is_open:
        ser.write(byte_data)

class PongDriver(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("FPGA Pong Input")
        self.geometry("350x450")
        
        self.ui_labels = {}
        
        tk.Label(self, text="Keyboard + PS4 Controller Input", font=("Arial", 12, "bold")).pack(pady=10)
        
        for key in controls:
            lbl = tk.Label(self, text=controls[key]['label'], width=30, height=2, 
                           bg="lightgray", relief="raised")
            lbl.pack(pady=5)
            # Map GUI labels to keys
            self.ui_labels[key] = lbl

        # Keyboard Bindings
        self.bind('<KeyPress>', self.on_key_press)
        self.bind('<KeyRelease>', self.on_key_release)
        
        # Poll Controller Loop
        self.after(10, self.poll_controller)
        
        self.protocol("WM_DELETE_WINDOW", self.on_close)

        # Track Paddle States for Controller logic
        # 0 = Neutral, 1 = Up, -1 = Down
        self.p1_state = 0 
        self.p2_state = 0

    # Keyboard input handling
    def on_key_press(self, event):
        key = event.keysym
        if key in controls and key not in active_keys:
            active_keys.add(key)
            send_uart(controls[key]['press'])
            self.ui_labels[key].config(bg="lime green")

    def on_key_release(self, event):
        key = event.keysym
        if key in controls and key in active_keys:
            active_keys.discard(key)
            send_uart(controls[key]['release'])
            self.ui_labels[key].config(bg="lightgray")

    # Controller input handling
    def poll_controller(self):
        if not joysticks:
            self.after(10, self.poll_controller)
            return

        pygame.event.pump() # Process hardware events

        # Read Analog Axes
        # Axis 1 is Left Stick Y, Axis 3 is Right Stick Y
        axis_p1 = joysticks[0].get_axis(1) 
        axis_p2 = joysticks[0].get_axis(3)

        # Player 1 control
        new_p1_state = 0
        if axis_p1 < -STICK_DEADZONE: new_p1_state = 1      # Move up
        elif axis_p1 > STICK_DEADZONE: new_p1_state = -1    # Move down

        if new_p1_state != self.p1_state:
            # If state has changed remove the old state
            if self.p1_state == 1: self.trigger_release('w')
            elif self.p1_state == -1: self.trigger_release('s')

            # Trigger new state
            if new_p1_state == 1: self.trigger_press('w')
            elif new_p1_state == -1: self.trigger_press('s')
            
            self.p1_state = new_p1_state

        # Player 2 control
        new_p2_state = 0
        if axis_p2 < -STICK_DEADZONE: new_p2_state = 1      # Move up
        elif axis_p2 > STICK_DEADZONE: new_p2_state = -1    # Move down

        if new_p2_state != self.p2_state:
            if self.p2_state == 1: self.trigger_release('Up')
            elif self.p2_state == -1: self.trigger_release('Down')

            if new_p2_state == 1: self.trigger_press('Up')
            elif new_p2_state == -1: self.trigger_press('Down')
            
            self.p2_state = new_p2_state

        # Run again in 10ms
        self.after(10, self.poll_controller)

    # Helper functions
    def trigger_press(self, key):
        if key not in active_keys:
            active_keys.add(key)
            send_uart(controls[key]['press'])
            self.ui_labels[key].config(bg="cyan")   # Make controller colour cyan

    def trigger_release(self, key):
        if key in active_keys:
            active_keys.discard(key)
            send_uart(controls[key]['release'])
            self.ui_labels[key].config(bg="lightgray")

    def on_close(self):
        print("Closing...")
        if ser and ser.is_open:
            for key in controls:
                ser.write(controls[key]['release'])
            ser.close()
        pygame.quit()
        self.destroy()

if __name__ == "__main__":
    app = PongDriver()
    app.mainloop()