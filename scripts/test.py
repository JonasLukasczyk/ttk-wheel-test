import vtk
import topologytoolkit as ttk

print("VTK version:", vtk.vtkVersion.GetVTKVersion())

# Create synthetic scalar field
source = vtk.vtkRTAnalyticSource()
source.SetWholeExtent(0, 30, 0, 30, 0, 30)
source.Update()

image = source.GetOutput()
print("Input:", image.GetClassName())
print("Input points:", image.GetNumberOfPoints())
print("Input scalar array:", image.GetPointData().GetScalars().GetName())

# Run TTK critical points filter
critical_points = ttk.ttkScalarFieldCriticalPoints()
critical_points.SetInputConnection(source.GetOutputPort())
critical_points.SetInputArrayToProcess("RTData",0)
critical_points.Update()

output = critical_points.GetOutput()

print("Output:", output.GetClassName())
print("Critical points:", output.GetNumberOfPoints())
print("Output arrays:")
for i in range(output.GetPointData().GetNumberOfArrays()):
    arr = output.GetPointData().GetArray(i)
    print(" -", arr.GetName(), arr.GetNumberOfTuples(), arr.GetNumberOfComponents())

print("OK")
