require 'formula'

class ImichkaInsighttoolkit < Formula
  homepage 'http://www.itk.org'
  url 'http://downloads.sourceforge.net/project/itk/itk/4.5/InsightToolkit-4.5.2.tar.gz'
  sha1 '91b14d4a67e837b3e0dc12d2d7ad5b3fdaae5a8e'
  head 'git://itk.org/ITK.git'

  bottle do
    root_url 'http://download.sf.net/project/macvtkitkpythonbottles/itk'
    revision 1
    sha1 'c24926a3691edb12ff4e103e49a6f76a316314de' => :mavericks
    sha1 'c24926a3691edb12ff4e103e49a6f76a316314de' => :mountain_lion
    sha1 '2ff126aa2a7179675aa8bde275db652710b9679d' => :lion
  end


  option :cxx11
  cxx11dep = (build.cxx11?) ? ['c++11'] : []

  depends_on 'cmake' => :build
  depends_on 'iMichka/MacVTKITKPythonBottles/imichka-vtk' => :build
  depends_on 'opencv' => [:optional] + cxx11dep
  depends_on :python => :optional
  depends_on 'fftw' => :recommended
  depends_on 'hdf5' => [:optional, '--enable-cxx'] + cxx11dep
  depends_on 'jpeg' => :recommended
  depends_on 'libpng' => :recommended
  depends_on 'libtiff' => :recommended

  option 'examples', 'Compile and install various examples'
  option 'with-itkv3-compatibility', 'Include ITKv3 compatibility'
  option 'remove-legacy', 'Disable legacy APIs'
  option 'with-review', 'Enable modules under review'

  def install

    args = std_cmake_args + %W[
      -DBUILD_TESTING=OFF
      -DBUILD_SHARED_LIBS=ON
      -DITK_USE_GPU=ON
      -DITK_USE_64BITS_IDS=ON
      -DITK_USE_STRICT_CONCEPT_CHECKING=ON
      -DITK_USE_SYSTEM_ZLIB=ON
      -DModule_ITKLevelSetsv4Visualization=ON
    ]
    args << ".."
    args << '-DBUILD_EXAMPLES=' + ((build.include? 'examples') ? 'ON' : 'OFF')
    args << '-DModule_ITKVideoBridgeOpenCV=' + ((build.with? 'opencv') ? 'ON' : 'OFF')
    args << '-DITKV3_COMPATIBILITY:BOOL=' + ((build.include? 'with-itkv3-compatibility') ? 'ON' : 'OFF')

    args << '-DITK_USE_SYSTEM_FFTW=ON' << '-DITK_USE_FFTWF=ON' << '-DITK_USE_FFTWD=ON' if build.with? 'fftw'
    args << '-DITK_USE_SYSTEM_HDF5=ON' if build.with? 'hdf5'
    args << '-DITK_USE_SYSTEM_JPEG=ON' if build.with? 'jpeg'
    args << '-DITK_USE_SYSTEM_PNG=ON' if build.with? 'libpng'
    args << '-DITK_USE_SYSTEM_TIFF=ON' if build.with? 'libtiff'
    args << '-DITK_LEGACY_REMOVE=ON' if build.include? 'remove-legacy'
    args << '-DModule_ITKReview=ON' if build.with? 'review'

    args << '-DVCL_INCLUDE_CXX_0X=ON' if build.cxx11?
    ENV.cxx11 if build.cxx11?

    mkdir 'itk-build' do
      if build.with? "python"
        args += %W[
          -DITK_WRAP_PYTHON=ON
          -DModule_ITKVtkGlue=ON
          -DCMAKE_C_FLAGS='-ansi'
        ]
        # CMake picks up the system's python dylib, even if we have a brewed one.
        args << "-DPYTHON_LIBRARY='#{%x(python-config --prefix).chomp}/lib/libpython2.7.dylib'"
      end
      system "cmake", *args
      system "make", "install"
    end
  end

  def post_install
    # Put manually the pth file in the site-packages folder
    # Waiting for modification of the ITK install script to have the following structure :
    # /Cellar/imichka-insighttoolkit/4.5.2/lib/python/site-packages
    if pour_bottle? and Formula.factory('python').installed?
      File.open("#{HOMEBREW_PREFIX}/lib/python2.7/site-packages/WrapITK.pth", 'w') {|f| f.write("#{HOMEBREW_PREFIX}/Cellar/imichka-insighttoolkit/4.5.2/lib/ITK-4.5/Python") }
    end
  end


end
