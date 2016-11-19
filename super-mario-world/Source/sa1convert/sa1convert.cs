// I'm sorry.
// EVERY tool I do it gets the source code messy.
// But what I mind is how well done is the final tool.
// - Vitor Vilela.

using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using VilelaBot2;

namespace SA1Convert
{
	class Program
	{
		static void Main(string[] args)
		{
			bool subFolders = false;
			string[] files = args;
		
			if(files.Length==1&&files[0].ToLower()=="-x")
			{
				files = new string[0];
				subFolders = true;
			}
		
			if(files.Length==0)
			{
				if (!subFolders)
				{
					files = Directory.GetFiles("./", "*.asm");
				}
				else
				{
					files = Directory.GetFiles("./", "*.asm", SearchOption.AllDirectories);
				}
			}
			
			if(files.Length==0)
			{
				Console.WriteLine("SA-1 Convert v1.10 - Sprites+Blocks Edition by Vitor Vilela.");
				Console.WriteLine("Usage: sa1convert [file 1] [file 2] ... [file n]");
				Console.WriteLine("Or just sa1convert without parameters to convert all files on directory.");
				Console.WriteLine("Also using \"sa1convert -x\" will tell SA-1 Convert");
				Console.WriteLine("to convert on all sub folders. Careful when using this option!");
				return;
			}
			
			foreach(string file in files)
			{
				if(!File.Exists(file))
				{
					Console.WriteLine("File {0} doesn't exist.", file);
					return;
				}
			}
			
			StringBuilder mainLog = new StringBuilder();
			
			List<bool> finish = new List<bool>();
			List<bool> success = new List<bool>();
			
			foreach(string f in files)
			{
				int id = finish.Count;
				finish.Add(false);
				success.Add(false);
				string file = f;
				Thread thread = new Thread(new ThreadStart(delegate()
				{
					string log;
					string clog;
					string data;
					string result;
					try
					{
						data = File.ReadAllText(file);
					}
					catch
					{
						Console.WriteLine("Couldn't read file {0}.", file);
						lock(finish)
						{
							finish[id]=true;
						}
						return;
					}
					
					//Console.WriteLine("Converting file '{0}'...", Path.GetFileName(file));
					
					try
					{
						result = new ASMConverter().ConvertSprite(data, out log, out clog);
					}
					catch (Exception ex)
					{
						Console.WriteLine("Internal error while converting file {0}.", file);
						Console.WriteLine(ex.ToString());
						lock(finish)
						{
							finish[id]=true;
						}
						return;
					}
					
					log = log.Trim('\r', '\n');
					clog = clog.Trim('\r', '\n');
					
					log = InsertFile(file, log);
					clog = InsertFile(file, clog);					
					
					lock(success)
					{
						success[id]=true;
					}
					
					if (clog.Length!=0)
					{
						Console.WriteLine(clog);
						
						lock(success)
						{
							success[id]=false;
						}
					}
					
					mainLog.AppendLine(log);
					
					if (result != null)
					{			
						try
						{
							if (clog.Length==0)
								File.WriteAllText(file, result, Encoding.Default);
						}
						catch (Exception ex)
						{
							Console.WriteLine("{0}: {1}", file, ex.Message);
						}
					}
					lock(finish)
					{
						finish[id]=true;
					}
				}));
				thread.Start();
			}

		wait:
			Thread.Sleep(1);
			lock(finish)
			{
				foreach(bool b in finish)
				{
					if(!b)
					{
						goto wait;
					}
				}
			}
			
			File.WriteAllText("conversion.log", mainLog.ToString());
			
			int ratio = 0;
			foreach (bool b in success) ratio += b ? 1 : 0;
			
			if(ratio == success.Count)
			{
				Console.WriteLine("All files were successful converted!");
			}
			else if(ratio != 0)
			{
				Console.WriteLine("{0} of {1} ({2:F}%) were successfully converted.", ratio, success.Count, ratio/(double)success.Count*100);
				Console.WriteLine("All sprites with errors weren't saved.");
			}
			else
			{
				Console.WriteLine("None of the sprites were converted.");
			}
			
			Console.Write("Press any key to quit...");
			Console.ReadKey(true);
			Console.WriteLine();
		}
		
		static string InsertFile(string file, string log)
		{
			if(log.Length == 0)
			{
				return "";
			}
			
			file = Path.GetFileName(file);
			string[] split = log.Split(new string[] { "\r\n" }, StringSplitOptions.None);
			for(int i=0;i<split.Length;++i)
			{
				split[i] = file+": " + split[i];
			}
			return string.Join("\r\n", split);
		}
	}
}