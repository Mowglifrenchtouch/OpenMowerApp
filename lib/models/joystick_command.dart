class JoystickCommand {
  final double lx;
  final double ly;
  final double rx;
  final double ry;

  const JoystickCommand(this.lx, this.ly, this.rx, this.ry);

  Map<String, dynamic> toJson() => {'lx': lx, 'ly': ly, 'rx': rx, 'ry': ry};
}
